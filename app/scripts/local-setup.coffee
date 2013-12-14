require [
  "jquery"
  "app"
  "../extension/scripts/hotkey"
], (
  $
  App
) ->
  class LocalSetup
    constructor: ->
      @loadCommands()
      App.on "execute.commands", @executeCommand

    loadCommands: ->
      $.getJSON("https://backtickio.s3.amazonaws.com/commands.json?t=#{Date.now()}")
        .success((response) => App.trigger "load.commands", response)
        .error(console.log.bind(console, "Error fetching commands"))

    executeCommand: (command) =>
      setTimeout ->
        alert("Commands can only be executed when running as an extension.")
        App.trigger "executed.commands"
      , 0

  new LocalSetup