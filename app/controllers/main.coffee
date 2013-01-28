Spine = require('spine')
{Panel} = require('spine.mobile')
Users = require('controllers/users')

class Error extends Panel
  title: 'Oops - something when wrong'

  constructor: ->
    super
    @addButton('Home', @home)
    @active @render

  home: ->
    @navigate '/home', trans: 'left'

  render: (params) =>
    @html require('views/main/error')(params)

class Home extends Panel
  className: 'main home'
  title: 'Give As You Go'

  constructor: ->
    super

    @addButton('My profile', @profile).addClass('hidden home')
    @addButton('Sign out', @signout).addClass('right hidden home')
    @addButton('Sign up', @signup).addClass('visible home')
    @addButton('Sign in', @signin).addClass('right visible home')

    @active @render

  render: ->
    @html require('views/main/home')

  profile: ->
    @navigate('/profile', trans: 'left')

  signout: ->
    Users.signout()
    @navigate('/home', trans: 'right')

  signup: ->
    @navigate('/signup', trans: 'left')

  signin: ->
    @navigate('/signin', trans: 'right')

class Main extends Spine.Controller
  constructor: ->
    super

    @home = new Home
    @error = new Error

    @routes
      '/home': (params) -> @home.active(params)
      '/error': (params) -> @error.active params

module.exports = Main
