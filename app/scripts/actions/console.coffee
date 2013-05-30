define [
  "app"
], (App) ->
  class ConsoleActions
    constructor: ->
      App.on "action:displayConsole", @displayConsole.bind(this)

    displayConsole: ->
      console.log "displaying console"

  new ConsoleActions
