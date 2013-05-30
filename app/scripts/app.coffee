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
      $("body").append Handlebars.compile(template)()

  new App