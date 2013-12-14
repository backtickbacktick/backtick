define [
  "jquery"
  "backbone"
  "app"
  "lib/extension"
  "lib/fuzzy-match"
], (
  $
  Backbone
  App
  Extension
  FuzzyMatch
) ->
  class Command extends Backbone.Model
    match: null

    getTemplateData: ->
      $.extend {}, @toJSON(), match: @match

    createMatch: (search) ->
      @match = new FuzzyMatch @get("name"), search

    execute: ->
      Extension.trigger "execute.commands", @attributes
      App.once "executed.commands", ->
        App.trigger "close"
