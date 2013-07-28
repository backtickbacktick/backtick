define [
  "underscore"
  "backbone"
  "app"
  "lib/constants"
  "views/base"
  "text!../../templates/console.hbs"
], (
  _
  Backbone
  App
  Constants
  BaseView
  template
) ->
  class ConsoleView extends BaseView
    rawTemplate: template

    events:
      "keydown": "onKeyDown"

    initialize: ->
      @$el = App.$console

      @render().in()

      @keepFocused()
      @escapeClose()

      App.on "close", @close.bind(this)
      App.on "open", @open.bind(this)

    open: ->
      @$input.val ""
      @in()

    close: ->
      @out()

    render: ->
      @$el.append @template()
      @$input = @$ "input"
      this

    focus: ->
      @$input.focus()
      this

    keepFocused: ->
      @on "in", @focus.bind(this)
      @$input.on "blur", =>
        _.defer @focus.bind(this) if App.open

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