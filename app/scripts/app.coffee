define [
  "underscore"
  "backbone"
], (
  _
  Backbone
) ->
  class App
    constructor: ->
      _.extend this, Backbone.Events

    start: ->
      @trigger "action:displayConsole"

  new App