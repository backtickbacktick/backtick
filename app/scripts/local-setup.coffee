require [
  "jquery"
  "app"
  "hotkey"
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

    executeCommand: (command) ->
       $.getScript(command.src)
        .success(App.trigger.bind(App, "executed.commands", command))
        .error(App.trigger.bind(App, "executionError.commands", command))

  new LocalSetup