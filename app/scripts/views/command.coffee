define [
  "underscore"
  "views/base"
  "text!../../templates/command.hbs"
], (
  _
  BaseView
  template
) ->
  class CommandView extends BaseView
    rawTemplate: template
    tagName: "li"
    className: "command"

    render: ->
      @$el.html @template(_.extend({}, @model.getTemplateData()))
      this
