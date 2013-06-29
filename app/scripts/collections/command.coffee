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

