require('lib/setup')

Spine   = require('spine')
{Stage} = require('spine.mobile')
Main = require('controllers/main')

class App extends Stage.Global
  constructor: ->
    super
    @main = new Main

    Spine.Route.setup(shim:true)
    @navigate '/home'

module.exports = App
