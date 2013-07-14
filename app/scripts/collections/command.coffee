define [
  "underscore"
  "backbone"
  "models/command"
  "lib/command-store"
], (
  _
  Backbone
  Command
  CommandStore
) ->
  class CommandCollection extends Backbone.Collection
    model: Command

    initialize: ->
      @fetch()

    sync: (method, collection, {success}) ->
      return super unless method is "read"
      _.defer success.bind(null, CommandStore.commands)

    filterMatches: (search) ->
      return [] unless search

      model.createMatch(search) for model in @models
      _.chain(@models)
        .filter((command) -> command.match.matches)
        .sortBy((command) -> -(command.match.weight))
        .value()

