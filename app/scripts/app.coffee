define [
  "underscore"
  "jquery"
  "backbone"
  "handlebars"
  "lib/extension"
  "text!../templates/root.hbs"
  "text!../templates/container.hbs"
], (
  _
  $
  Backbone
  Handlebars
  Extension
  rootTemplate
  containerTemplate
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
      @$el = $(Handlebars.compile(rootTemplate)()).appendTo "body"

      createShadowRoot = @$el[0].createShadowRoot or @$el[0].webkitCreateShadowRoot
      shadow = createShadowRoot.apply @$el[0]

      cssPath = "styles/style.css"
      cssPath = chrome.extension.getURL(cssPath) if chrome.extension
      shadow.innerHTML = Handlebars.compile(containerTemplate)(cssPath: cssPath)

      @$console = $ shadow.querySelector("#console")
      @$results = $ shadow.querySelector("#results")
      @$settings = $ shadow.querySelector("#settings")

  new App