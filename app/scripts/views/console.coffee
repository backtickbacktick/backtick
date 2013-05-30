define [
  "backbone"
  "app"
  "views/base"
  "text!../../templates/console.hbs"
], (
  Backbone
  App
  BaseView
  template
) ->
  class ConsoleView extends BaseView
    rawTemplate: template
    el: "#__backtick__console"

    render: ->
      @$el.append @template()
      this

    focus: ->
      @$("input").focus()
      this
