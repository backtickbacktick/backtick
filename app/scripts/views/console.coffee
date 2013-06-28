define [
  "backbone"
  "app"
  "views/base"
  "collections/command"
  "text!../../templates/console.hbs"
], (
  Backbone
  App
  BaseView
  CommandCollection
  template
) ->
  class ConsoleView extends BaseView
    rawTemplate: template
    el: "#__backtick__console"

    initialize: ->
      @commandCollection = new CommandCollection
      @commandCollection.fetch()
      @commandCollection.on "sync", =>
        console.log @commandCollection
        console.log "synced commands"

    render: ->
      @$el.append @template()
      this

    focus: ->
      @$("input").focus()
      this
