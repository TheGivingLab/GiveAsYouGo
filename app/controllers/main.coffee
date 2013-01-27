Spine = require('spine')
{Panel} = require('spine.mobile')

class Error extends Panel
  title: 'Oops - something when wrong'

  constructor: ->
    super
    @addButton('Home', @home)
    @active @render

  home: ->
    @navigate '/home', trans: 'left'

  render: (params) =>
    @log 'Error'
    @html require('views/main/error')(params)

class Home extends Panel
  className: 'main home'
  title: 'Powered by The GivingLab'

  constructor: ->
    super

    Main.bind('refresh change', @render)
    @addButton('Sign up', @signup)
    @addButton('Sign in', @signin).addClass('right')

    @active @render

  render: =>
    @html require('views/main/home')

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
