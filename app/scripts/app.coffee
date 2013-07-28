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
      @$el = $("<div id=\"__backtick__\">").appendTo "body"

      createShadowRoot = @$el[0].createShadowRoot or @$el[0].webkitCreateShadowRoot
      shadow = createShadowRoot.apply @$el[0]
      shadow.innerHTML = Handlebars.compile(template)()

      @$console = $ shadow.querySelector("#console")
      @$results = $ shadow.querySelector("#results")
      @$settings = $ shadow.querySelector("#settings")

  new App