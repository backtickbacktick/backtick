define [
  "jquery"
  "backbone"
  "app"
  "lib/fuzzy-search"
], (
  $
  Backbone
  App
  FuzzySearch
) ->
  class Command extends Backbone.Model
    match: (search) ->
      FuzzySearch.match search, @get "name"

    weight: (search) ->
      FuzzySearch.weight search, @get "name"

    execute: ->
      $.getScript(@get "src")
        .success(App.trigger.bind(App, "close"))
        .error(console.log.bind(console, "Error loading script"))
