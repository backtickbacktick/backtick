define [
  "underscore"
  "backbone"
  "app"
  "lib/constants"
  "views/base"
  "collections/command"
  "views/results"
  "text!../../templates/console.hbs"
], (
  _
  Backbone
  App
  Constants
  BaseView
  CommandCollection
  ResultsView
  template
) ->
  class ConsoleView extends BaseView
    rawTemplate: template
    el: "#_bt-console"

    events:
      "keydown": "onKeyDown"

    initialize: ->
      @render().in()
      @once "in", @focus.bind(this)
      App.once "close", @out.bind(this)

    render: ->
      @$el.append @template()
      @$input = @$ "input"
      this

    focus: ->
      @$input.focus()
      this

    onKeyDown: (e) ->
      switch e.which
        when Constants.Keys.ENTER
          e.preventDefault()
          App.trigger "execute"
        else
          _.defer => App.trigger "search", @$input.val()
