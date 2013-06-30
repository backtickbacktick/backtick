define [
  "backbone"
  "handlebars"
  "lib/constants"
], (
  Backbone
  Handlebars
  Constants
) ->
  class BaseView extends Backbone.View
    rawTemplate: ""
    compile: Handlebars.compile.bind(Handlebars)

    constructor: ->
      @template = @compile @rawTemplate
      super

    in: ->
      @$el.removeClass("out").addClass "in"
      @$el.one "#{Constants.TRANSITION_END} #{Constants.ANIMATION_END}", \
        @trigger.bind(this, "in")
      this

    out: ->
      @$el.removeClass("in").addClass "out"
      @$el.one "#{Constants.TRANSITION_END} #{Constants.ANIMATION_END}", \
        @trigger.bind(this, "out")
      this

    isRendered: ->
      not @$el.is ":empty"