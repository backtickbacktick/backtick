define [
  "views/base"
], (
  BaseView
) ->
  class CommandView extends BaseView
    tagName: "li"
    render: ->
      @$el.append @model.get "name"
      this
