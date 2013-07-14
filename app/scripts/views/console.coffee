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

      @keepFocused()
      @escapeClose()

      App.once "close", @out.bind(this)

    render: ->
      @$el.append @template()
      @$input = @$ "input"
      this

    focus: ->
      @$input.focus()
      this

    keepFocused: ->
      @$input.on "blur", => _.defer @focus.bind(this)

    escapeClose: ->
      $(document).on "keyup", (e) ->
        App.trigger("close") if e.which is Constants.Keys.ESCAPE

    onKeyDown: (e) ->
      preventDefault = true

      switch e.which
        when Constants.Keys.ENTER
          App.trigger "command:execute"
        when Constants.Keys.ARROW_UP
          App.trigger "command:navigateUp"
        when Constants.Keys.ARROW_DOWN
          App.trigger "command:navigateDown"
        else
          preventDefault = false
          _.defer => App.trigger "command:search", @$input.val()

      e.preventDefault() if preventDefault