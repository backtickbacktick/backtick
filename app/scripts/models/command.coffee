define [
  "backbone"
  "lib/fuzzy-search"
], (
  Backbone
  FuzzySearch
) ->
  class Command extends Backbone.Model
    match: (search) ->
      FuzzySearch.match search, @get "name"

    weight: (search) ->
      FuzzySearch.weight search, @get "name"
