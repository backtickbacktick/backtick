require [
  "jquery"
  "app"
], (
  $
  App
) ->
  class LocalSetup
    constructor: ->
      @loadCommands()
      App.on "execute.commands", @executeCommand.bind(this)

    loadCommands: ->
      $.getJSON("http://dev.api.backtick.io/commands")
        .success((response) => App.trigger "load.commands", response)
        .error(console.log.bind(console, "Error fetching commands"))

    executeCommand: (src) ->
       $.getScript(src)
        .success(App.trigger.bind(App, "executed.commands"))
        .error(console.log.bind(console, "Error loading script"))

  new LocalSetup