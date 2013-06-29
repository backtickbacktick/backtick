define [
  "backbone"
  "views/base"
  "collections/command"
  "views/results"
  "text!../../templates/console.hbs"
], (
  Backbone
  BaseView
  CommandCollection
  ResultsView
  template
) ->
  class ConsoleView extends BaseView
    rawTemplate: template
    el: "#__backtick__console"

    initialize: ->
      @render().in().focus()
      @commandCollection = new CommandCollection
      @commandCollectionView = new ResultsView \
        collection: @commandCollection

    render: ->
      @$el.append @template()
      this

    focus: ->
      @$("input").focus()
      this
