define [
  "views/base"
  "views/command"
], (
  BaseView
  CommandView
) ->
  class ResultsView extends BaseView
    el: "#__backtick__results"
    commandViews: []

    initialize: ->
      @collection.on "sync", =>
        @createModelViews()
        @render()

    createModelViews: ->
      @collection.each (command) =>
        view = new CommandView model: command
        @commandViews.push view

    render: ->
      $ul = $ "<ul>"
      for view in @commandViews
        $ul.append view.render().el

      @$el.append $ul
      console.log @$el
      this

