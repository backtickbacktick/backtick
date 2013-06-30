define [
  "app"
  "views/base"
  "views/command"
], (
  App
  BaseView
  CommandView
) ->
  class ResultsView extends BaseView
    el: "#_bt-results"
    commandViews: []
    activeCommand: null

    initialize: ->
      @collection.on "sync", =>
        @createModelViews()

      App.on "search", @renderMatches.bind this
      App.on "execute", @executeActive.bind this
      App.once "close", @remove.bind this

    createModelViews: ->
      @collection.each (command) =>
        view = new CommandView model: command
        command.view = view
        @commandViews.push view

    remove: ->
      @$el.remove()

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
        .map (model) -> model.view.render search

      @activeCommand = @commandViews[0]?.model
      @render()

    renderMatches: _.debounce ResultsView::_renderMatches, 100

    executeActive: ->
      @activeCommand?.execute()
