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
      App.on "fetch.commands", @fetchCommand

    loadCommands: ->
      $.getJSON("https://backtickio.s3.amazonaws.com/commands.json?t=#{Date.now()}")
        .success((response) => App.trigger "load.commands", response)
        .error(console.log.bind(console, "Error fetching commands"))

    fetchCommand: (command) =>
      setTimeout ->
        App.trigger "fetched.commands",
          "alert('Commands can only be executed when running as an extension.')"
      , 0

  new LocalSetup