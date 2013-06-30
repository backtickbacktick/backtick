define [
  "underscore"
  "app"
  "collections/command"
  "views/console"
  "views/results"
], (
  _
  App
  CommandCollection
  ConsoleView
  ResultsView
) ->
  class Actions
    constructor: ->
      App.on "action:initConsole", @initConsole.bind this

    initConsole: ->
      new ConsoleView
      new ResultsView collection: new CommandCollection

  new Actions
