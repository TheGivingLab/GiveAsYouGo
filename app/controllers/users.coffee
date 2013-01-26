Spine = require('spine')
{Panel} = require('spine.mobile')

# Require models
User = require('models/user')

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
    @addButton('Sign up', @signup)
    @addButton('Sign in', @signin).addClass('right')
    @active -> @render()
  render: ->
    @html require('views/signin/form')()
  signup: ->
    @navigate('/signup', trans: 'left')
  signin: ->
    @navigate('/profile', trans: 'right')
  formData: ->
    Email = @form.find('[name=Email]').val()
    Password = @form.find('[name=Password]').val()
    {Email: Email, Password: Password}

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
