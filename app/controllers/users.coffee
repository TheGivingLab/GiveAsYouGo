Spine   = require('spine')
$       = Spine.$
{Panel} = require('spine.mobile')
env = require 'environment'

# Require models
User = require 'models/user'

GivingLabHandler =
  glauth: (data, action) ->
    data.apikey = env.GIVINGLAB_API_KEY
    @log 'auth', data
    $.ajax
      type: 'POST'
      url: 'https://www.thegivinglab.org/api/users/' + action
      data: data
      dataType: 'jsonp'
      error: (jqXHR, textStatus, errorThrown) =>
        @log 'error:', jqXHR, status, error
        @navigate '/error',
          trans: 'right'
          msg: "Failed to authenticate with The Giving Lab"
          data:
            status: status
            jqXHR: jqXHR
            error: error
      success: (data, textStatus, jqXHR) =>
        @log 'success:', data, textStatus, jqXHR
        @navigate '/home', trans: 'left'

FacebookHandler =
  fbauth: (action) ->
    FB.getLoginStatus (response) =>
      if response.status == 'connected'
        @log 'connected via FB', response
        @glauth
          FacebookToken: response.authResponse.accessToken
        , 'authenticate'
      else
        @log 'not logged in via FB', response
        FB.login (response) =>
          if response.authResponse
            @log 'authorized', response
            if action == 'signin'
              @glauth
                FacebookToken: response.authResponse.accessToken
              , 'authenticate'
            else if action == 'signup'
              @glauth
                FacebookAccessToken: response.authResponse.accessToken
              , 'createuser'
          else
            @log 'Authorization denied', response
            @navigate '/error',
              trans: 'right'
              msg: "Authorization was denied"
              data:
                response: response
        , { scope: 'email' }

class UsersSignup extends Panel
  @include GivingLabHandler
  @include FacebookHandler
  title: 'Sign up'
  className: 'users signup'
  elements:
    'form': 'form'
  constructor: ->
    super
    @addButton('Sign up via facebook', @fbsignup)
    @addButton('Sign up', @signup).addClass('right')
    # Render the view, resetting the form
    @bind 'active', @render()
  render: ->
    @html require('views/signup/form')()
  fbsignup: ->
    @fbauth 'signup'
  signup: (e) ->
    e.preventDefault()
    @log @formData()
    @glauth @formData(), 'registeruser'
    user = User.create(@formData())
    @navigate '/profile', trans: 'right' if user
  back: ->
    @form.blur()
    @navigate '/signin', trans: 'left'
  formData: ->
    {
      Forename: @form.find('[name=Forename]').val()
      Surname: @form.find('[name=Surname]').val()
      Email: @form.find('[name=Email]').val()
      Password: @form.find('[name=Password]').val()
    }

class UsersSignin extends Panel
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
    @active -> @render()
  render: ->
    @html require('views/signin/form')()
  fbsignin: ->
    @fbauth 'signin'
  signin: (e) ->
    e.preventDefault()
    @log @formData()
    @glauth @formData(), 'authenticate'
  formData: ->
    {
      Username: @form.find('[name=Email]').val()
      Password: @form.find('[name=Password]').val()
    }

class Users extends Spine.Controller
  constructor: ->
    super
    # The panels
    @signup = new UsersSignup
    @signin = new UsersSignin
    # Routing
    @routes
      '/signup': (params) -> @signup.active(params)
      '/signin': (params) -> @signin.active(params)
    # Fetch from local storage
    User.fetch()

module.exports = Users
