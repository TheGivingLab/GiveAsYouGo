Spine   = require('spine')
$       = Spine.$
{Panel} = require('spine.mobile')
env = require 'environment'

# Require models
User = require 'models/user'

GivingLabHandler =
  glauth: (data, action) ->
    data.apikey = env.GIVINGLAB_API_KEY
    @log '[GivingLabHandler.glauth] data:', data if env.DEBUG
    $.ajax
      type: 'POST'
      url: 'https://www.thegivinglab.org/api/users/' + action
      data: data
      dataType: 'jsonp'
      error: (jqXHR, status, error) =>
        @log '[GivingLabHandler.glauth] error:', jqXHR, status, error if env.DEBUG
        @navigate '/error',
          trans: 'right'
          msg: "Failed to authenticate with The Giving Lab"
          data:
            status: status
            jqXHR: jqXHR
            error: error
      success: (data, textStatus, jqXHR) =>
        @log '[GivingLabHandler.glauth] success:', data, textStatus, jqXHR if env.DEBUG
        user = User.findByAttribute(ID: data.ID)?.updateAttributes(data) or User.create(data)
        if user
          Users.signin user
          @navigate '/profile', trans: 'right'
        else
          @navigate '/error',
            trans: 'right'
            msg: "Failed to create a User"
            data:
              user: data

FacebookHandler =
  fbauth: (action) ->
    FB.getLoginStatus (response) =>
      if response.status == 'connected'
        @log '[FacebookHandler.fbauth] connected:', response if env.DEBUG
        @glauth
          FacebookToken: response.authResponse.accessToken
        , 'authenticate'
      else
        @log '[FacebookHandler.fbauth] not logged in:', response if env.DEBUG
        FB.login (response) =>
          if response.authResponse
            @log '[FacebookHandler.fbauth] authorized:', response if env.DEBUG
            if action == 'signin'
              @glauth
                FacebookToken: response.authResponse.accessToken
              , 'authenticate'
            else if action == 'signup'
              @glauth
                FacebookAccessToken: response.authResponse.accessToken
              , 'createuser'
          else
            @log '[FacebookHandler.fbauth] Authorization denied:', response if env.DEBUG
            @navigate '/error',
              trans: 'right'
              msg: "Authorization was denied"
              data:
                response: response
        , { scope: 'email' }

class UserSignup extends Panel
  @include GivingLabHandler
  @include FacebookHandler

  title: 'Sign up'
  className: 'users signup'
  events:
    'submit form': 'signup'
  elements:
    'form': 'form'

  constructor: ->
    super
    @addButton('Sign up via facebook', @fbsignup)
    @addButton('Sign up', @signup).addClass('right')
    # Render the view, resetting the form
    @active -> @render()

  render: ->
    @html require('views/signup/form')()

  fbsignup: ->
    @fbauth 'signup'

  signup: (e) ->
    e.preventDefault()
    formData =
      Forename: @form.find('[name=Forename]').val()
      Surname: @form.find('[name=Surname]').val()
      Email: @form.find('[name=Email]').val()
      Password: @form.find('[name=Password]').val()
    @log '[UserSignup.signup] form data:', formData if env.DEBUG
    @glauth formData, 'registeruser'

class UserSignin extends Panel
  @include GivingLabHandler
  @include FacebookHandler

  title: 'Sign in'
  className: 'users signin'
  events:
    'submit form': 'signin'
  elements:
    'form': 'form'

  constructor: ->
    super
    @addButton('Sign in via facebook', @fbsignin)
    @addButton('Sign in', @signin).addClass('right')
    # Render the view, resetting the form
    @active -> @render()

  render: ->
    @html require('views/signin/form')()

  fbsignin: ->
    @fbauth 'signin'

  signin: (e) ->
    e.preventDefault()
    formData =
      Username: @form.find('[name=Email]').val()
      Password: @form.find('[name=Password]').val()
    @log '[UserSignin.signin] form data:', formData if env.DEBUG
    @glauth formData, 'authenticate'

class UserProfile extends Panel
  title: 'Your profile'
  className: 'users profile'

  constructor: ->
    super
    @addButton('Home', @home)
    @addButton('Sign out', @signout).addClass('right')
    @active (params) -> @render(params)

  render: (params)->
    @html require('views/user/profile')(params.user or Users.user or User.first())

  home: ->
    @navigate '/home', trans: 'left'

  signout: ->
    Users.signout()
    @navigate '/home', trans: 'right'

class Users extends Spine.Controller
  @toggleBtns: ->
    hidden = $('button.hidden')
    visible = $('button.visible')
    console.log '[Users.toggleBtns] hidden:', hidden, 'visible:', visible if env.DEBUG
    hidden.removeClass('hidden').addClass('visible')
    visible.removeClass('visible').addClass('hidden')

  @signin: (user) ->
    console.log '[Users.signin] user:', user if env.DEBUG
    @toggleBtns()
    @user = user

  @signout: () ->
    console.log '[Users.signout] signout:', @user if env.DEBUG
    @toggleBtns()
    @user = null

  constructor: ->
    super
    # Fetch from local storage
    User.fetch()
    # The panels
    @signup = new UserSignup
    @signin = new UserSignin
    @profile = new UserProfile
    # Routing
    @routes
      '/signup': (params) -> @signup.active(params)
      '/signin': (params) -> @signin.active(params)
      '/profile': (params) -> @profile.active(params)

module.exports = Users
