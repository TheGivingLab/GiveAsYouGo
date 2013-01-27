Spine = require('spine')
{Panel} = require('spine.mobile')

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

    @routes
      '/home': (params) -> @home.active(params)

module.exports = Main
