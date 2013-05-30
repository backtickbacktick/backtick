define [
  "backbone"
  "handlebars"
], (
  Backbone,
  Handlebars
) ->
  class BaseView extends Backbone.View
    rawTemplate: ""
    compile: Handlebars.compile.bind(Handlebars)

    constructor: ->
      @template = @compile @rawTemplate
      super()

    in: ->
      @$el.removeClass("out").addClass "in"
      this

    out: ->
      @$el.removeClass("in").addClass "out"
      this

