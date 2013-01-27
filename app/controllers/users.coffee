Spine   = require('spine')
$       = Spine.$
{Panel} = require('spine.mobile')
env = require 'environment'

# Require models
User = require 'models/user'

class UsersSignup extends Panel
  title: 'Sign up'
  className: 'users signup'
  elements:
    'form': 'form'
  constructor: ->
    super
    @addButton('< Back', @back)
    @addButton('Sign up', @signup).addClass('right')
    # Render the view, resetting the form
    @bind 'active', @render()
  render: ->
    @html require('views/signup/form')()
  signup: ->
    user = User.create(@formData())
    @navigate('/profile', trans: 'right') if user
  back: ->
    @form.blur()
    @navigate('/signin', trans: 'left')
  formData: ->
    Forename = @form.find('[name=Forename]').val()
    Surname = @form.find('[name=Surname]').val()
    Email = @form.find('[name=Email]').val()
    Password = @form.find('[name=Password]').val()
    {Forename: Forename, Surname: Surname, Email: Email, Password: Password}

class UsersSignin extends Panel
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
    @navigate '/fbsignin', trans: 'left'
  signin: (e) ->
    e.preventDefault()
    @log @formData()
    @auth @formData()
  formData: ->
    {
      Username: @form.find('[name=Email]').val()
      Password: @form.find('[name=Password]').val()
    }

  auth: (data) ->
    data.apikey = env.GIVINGLAB_API_KEY
    @log 'auth', data
    $.ajax
      type: 'POST'
      url: 'https://www.thegivinglab.org/api/users/authenticate'
      data: data
      dataType: 'jsonp'
      error: (jqXHR, textStatus, errorThrown) =>
        @log 'error:', jqXHR, textStatus, errorThrown
      success: (data, textStatus, jqXHR) =>
        @log 'success:', data, textStatus, jqXHR
      complete: (jqXHR, textStatus) =>
        @log 'complete:', textStatus, jqXHR
        @navigate '/home', trans: 'left'

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
      '/fbsignin': (params) -> @fbsignin(params)
    # Fetch from local storage
    User.fetch()

  fbsignin: ->
    FB.getLoginStatus (response) =>
      if response.status == 'connected'
        @log 'connected via FB', response
        @signin.auth
          FacebookToken: response.authResponse.accessToken
      else
        @log 'not logged in via FB', response
        FB.login (response) =>
          if response.authResponse
            @log 'authorized', response
            @signin.auth
              FacebookToken: response.authResponse.accessToken
          else
            @log 'Authorization denied', response
            @navigate '/signin', trans: 'right'
        , { scope: 'email' }

module.exports = Users
