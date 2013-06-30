define [
  "underscore"
  "views/base"
  "lib/fuzzy-search"
  "text!../../templates/command.hbs"
], (
  _
  BaseView
  FuzzySearch
  template
) ->
  class CommandView extends BaseView
    rawTemplate: template
    tagName: "li"

    render: (search = "") ->
      @$el.html @template(_.extend({}, @model.toJSON(), search: search))
      this
