require [
  "jquery"
  "app"
], (
  $
  App
) ->
  $.getJSON("http://dev.api.backtick.io/commands")
    .success((response) => App.trigger "load.commands", response)
    .error(console.log.bind(console, "Error fetching commands"))
