define [
  "jquery"
  "backbone"
  "app"
  "lib/fuzzy-match"
], (
  $
  Backbone
  App
  FuzzyMatch
) ->
  class Command extends Backbone.Model
    match: null

    getTemplateData: ->
      $.extend {}, @toJSON(), match: @match

    createMatch: (search) ->
      @match = new FuzzyMatch @get("name"), search

    execute: ->
      $.getScript(@get "src")
        .success(App.trigger.bind(App, "close"))
        .error(console.log.bind(console, "Error loading script"))
