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

    createModelViews: ->
      @collection.each (command) =>
        view = new CommandView model: command
        command.view = view
        @commandViews.push view

    render: ->
      @$el.empty()
      return unless @commandViews.length
      $ul = $ "<ul>"
      for view in @commandViews
        view.render() unless view.isRendered()
        $ul.append view.el

      @$el.append $ul
      this

    _lastSearch: ""
    _renderMatches: (search) ->
      return if @_lastSearch is search
      @_lastSearch = search

      @commandViews = @collection.filterMatches(search)
        .map (model) -> model.view.highlightMatches search

      @render()

    renderMatches: _.debounce ResultsView::_renderMatches, 100
