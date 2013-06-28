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
    sync: (method, collection, {success}) ->
      if method is "read"
        _.defer success.bind(null, CommandStore.commands)
        return

      super
