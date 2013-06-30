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
      $("body").append $("<script>").attr("src", @get("src"))
      App.trigger "close"
