define [
  "underscore"
  "backbone"
  "app"
  "models/command"
], (
  _
  Backbone
  App
  Command
) ->
  class CommandCollection extends Backbone.Collection
    model: Command

    initialize: ->
      App.on "sync.commands load.commands", _.defer.bind(_, @fetch.bind(this))

    sync: (method, collection, {success}) ->
      return super unless method is "read"
      _.defer success.bind(null, App.commands)

    filterMatches: (search) ->
      return [] unless search

      model.createMatch(search) for model in @models
      _.chain(@models)
        .filter((command) -> command.match.matches)
        .sortBy((command) -> -(command.match.weight))
        .value()

