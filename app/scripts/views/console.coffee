define [
  "underscore"
  "backbone"
  "views/base"
  "collections/command"
  "views/results"
  "text!../../templates/console.hbs"
], (
  _
  Backbone
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

      @commandCollection = new CommandCollection
      @resultsView = new ResultsView \
        collection: @commandCollection

    render: ->
      @$el.append @template()
      @$input = @$ "input"
      this

    focus: ->
      @$input.focus()
      this

    onKeyDown: (e) ->
      _.defer => @resultsView.renderMatches @$input.val()