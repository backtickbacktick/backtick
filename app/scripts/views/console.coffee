define [
  "underscore"
  "backbone"
  "app"
  "lib/extension"
  "lib/constants"
  "views/base"
  "text!../../templates/console.hbs"
], (
  _
  Backbone
  App
  Extension
  Constants
  BaseView
  template
) ->
  class ConsoleView extends BaseView
    rawTemplate: template

    events:
      "click .settings": "openSettings"

    initialize: ->
      @$el = App.$console

      @render().in()

      @keepFocused()
      @escapeClose()

      document.addEventListener "keydown", @onKeyDown, true

      App.on "load.commands sync.commands",  =>
        return unless @$input
        return unless @$input?.val()

        App.trigger "command:search", @$input.val(), true

      App.on
        "close": @close
        "open": @open
        "fetch.commands": @displayName.bind this

    open: =>
      @$input.val ""
      @in()

    close: =>
      @out()
      @once "out", => @$input.blur()

    render: ->
      @$el.append @template()
      @$input = @$ "input"
      this

    focus: =>
      @$input.focus()
      this

    keepFocused: ->
      @on "in", @focus
      @$input.on "blur", =>
        _.defer(@focus) if App.open

    escapeClose: ->
      $(document).on "keyup", (e) ->
        App.trigger("close") if e.which is Constants.Keys.ESCAPE

    displayName: (command) ->
      @$input.val command.name

    openSettings: ->
      Extension.trigger "open.settings"

    onKeyDown: (e) =>
      return unless App.open
      e.stopPropagation()
      preventDefault = true
      unless App.loading
        switch e.which
          when Constants.Keys.ENTER
            App.trigger "command:execute"
          when Constants.Keys.ARROW_UP
            App.trigger "command:navigateUp", @$input.val()
          when Constants.Keys.ARROW_DOWN
            App.trigger "command:navigateDown", @$input.val()
          else
            preventDefault = false
            _.defer => App.trigger "command:search", @$input.val()

      e.preventDefault() if preventDefault