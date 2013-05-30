define [
  "underscore"
  "jquery"
  "backbone"
  "handlebars"
  "text!../templates/container.hbs"
], (
  _
  $
  Backbone
  Handlebars
  template
) ->
  class App
    constructor: ->
      _.extend this, Backbone.Events

    start: ->
      @appendContainer()
      @trigger "action:displayConsole"

    appendContainer: ->
      @$el = $ Handlebars.compile(template)()
      @$console = @$el.find "#__backtick__console"
      @$results = @$el.find "#__backtick__results"
      @$settings = @$el.find "#__backtick__settings"

      $("body").append @$el

  new App