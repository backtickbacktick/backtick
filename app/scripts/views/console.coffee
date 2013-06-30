define [
  "underscore"
  "backbone"
  "app"
  "views/base"
  "collections/command"
  "views/results"
  "text!../../templates/console.hbs"
], (
  _
  Backbone
  App
  BaseView
  CommandCollection
  ResultsView
  template
) ->
  class ConsoleView extends BaseView
    rawTemplate: template
    el: "#__backtick__console"

    events:
      "keydown": "onKeyDown"

    initialize: ->
      @render().in()
      @once "in", @focus.bind(this)

    render: ->
      @$el.append @template()
      @$input = @$ "input"
      this

    focus: ->
      @$input.focus()
      this

    onKeyDown: (e) ->
      _.defer => App.trigger "search", @$input.val()
