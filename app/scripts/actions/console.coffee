define [
  "app"
  "views/console"
], (App, ConsoleView) ->
  class ConsoleActions
    constructor: ->
      App.on "action:displayConsole", @displayConsole.bind(this)

    displayConsole: ->
      new ConsoleView

  new ConsoleActions
