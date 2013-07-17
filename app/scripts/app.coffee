define [
  "underscore"
  "jquery"
  "backbone"
  "handlebars"
  "lib/extension"
  "text!../templates/container.hbs"
], (
  _
  $
  Backbone
  Handlebars
  Extension
  template
) ->
  class App
    open: false
    commands: []

    constructor: ->
      _.extend this, Backbone.Events

      @on "open", => @open = true
      @on "close", => @open = false

    start: ->
      @appendContainer()
      @trigger "loadConsole.action"

      @on "load.commands", => @open = true
      @on "load.commands sync.commands", (commands) => @commands = commands

      Extension.trigger "ready.app"

      @on "toggleClose", ->
        if @open
          @trigger "close"
        else
          @trigger "open"

    appendContainer: ->
      @$el = $ Handlebars.compile(template)()

      # Temporary way to switch between themes
      @$el.addClass "light" if location.hash is "#light"

      @$console = @$el.find "#_bt-console"
      @$results = @$el.find "#_bt-results"
      @$settings = @$el.find "#_bt-settings"

      $("body").append @$el

  new App