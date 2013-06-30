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
        @trigger "action:initConsole"

    appendContainer: ->
      @$el = $ Handlebars.compile(template)()

      # Temporary way to switch between themes
      @$el.addClass "light" if location.hash is "#light"

      @$console = @$el.find "#_bt-console"
      @$results = @$el.find "#_bt-results"
      @$settings = @$el.find "#_bt-settings"

      $("body").append @$el

  new App