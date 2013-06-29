define [
  "underscore"
  "jquery"
  "backbone"
  "handlebars"
  "lib/command-store"
  "text!../templates/container.hbs"
], (
  _
  $
  Backbone
  Handlebars
  CommandStore
  template
) ->
  class App
    constructor: ->
      _.extend this, Backbone.Events

    start: ->
      CommandStore.init()
      CommandStore.on "synced", =>
        @appendContainer()
        @trigger "action:displayConsole"

    appendContainer: ->
      @$el = $ Handlebars.compile(template)()

      # Temporary way to switch between themes
      @$el.addClass "light" if location.hash is "#light"

      @$console = @$el.find "#__backtick__console"
      @$results = @$el.find "#__backtick__results"
      @$settings = @$el.find "#__backtick__settings"

      $("body").append @$el

  new App