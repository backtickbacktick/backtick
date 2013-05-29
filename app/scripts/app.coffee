define [
  "underscore"
  "backbone"
], (
  _
  Backbone
) ->
  class App
    constructor: ->
      _.extend(this, Backbone.Events)
      @trigger "action:displayConsole"
