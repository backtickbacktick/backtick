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
      Extension.trigger "fetch.commands", @attributes
      App.once "fetched.commands", (src) =>
        try
          src = decodeURIComponent src
        catch e
          # Do nothing

        window.location = "javascript:#{encodeURIComponent src}"
        App.trigger "close"
