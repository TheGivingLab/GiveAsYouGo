require('lib/setup')

Spine   = require('spine')
{Stage} = require('spine.mobile')
Main = require('controllers/main')
Users = require('controllers/users')

class App extends Stage.Global
  constructor: ->
    super
    @main = new Main

    # Instantiate Users controller
    new Users
    Spine.Route.setup(shim:true)
    @navigate '/home'

module.exports = App
