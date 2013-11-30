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
    resultsVisible: false
    commandViews: []
    selectedCommand: null
    selectedCommandIndex: 0

    initialize: ->
      @$el = App.$results
      @collection.on "sync", =>
        @createModelViews()

      App.on "command:search", @renderMatches.bind(this)
      App.on "command:navigateDown", (search) =>
        if search.length is 0 and not @resultsVisible
          @listAll()
        else
          @cycleSelected 1

      App.on "command:navigateUp", @cycleSelected.bind this, -1
      App.on "command:execute", @executeSelected
      App.on "executionError.commands", (command) =>
        alert "Backtick failed to run command \"#{command.name}\""
        @_lastSearch = undefined
        @_renderMatches command.name

      App.on "close", @empty

    createModelViews: ->
      @collection.each (command) =>
        view = new CommandView model: command
        command.view = view
        @commandViews.push view

    remove: ->
      @resultsVisible = false
      @$el.remove()

    listAll: ->
      @commandViews = @collection
        .sortBy((command) -> command.get("name").toLowerCase())
        .map((command) ->
          command.match = null
          command.view.render()
        )

      @render()
      @setSelected 0

    empty: =>
      @commandViews = []
      @selectedCommand = null
      @selectedCommandIndex = 0
      @resultsVisible = false
      @$el.empty()

    render: ->
      @$el.empty()
      @resultsVisible = false
      return unless @commandViews.length and App.open
      $ul = $ "<ul>"
      for view in @commandViews
        view.render() unless view.isRendered()
        view.delegateEvents()
        $ul.append view.el

      @$el.append $ul
      @resultsVisible = true
      @maxHeight = parseInt @$el.css("max-height"), 10
      this

    _lastSearch: ""
    _renderMatches: (search, force) =>
      return if @_lastSearch is search and not force
      @_lastSearch = search
      return @listAll() if search is ""

      @commandViews = @collection.filterMatches(search)
        .map (model) -> model.view.render()

      @render()
      @setSelected 0

    renderMatches: _.debounce ResultsView::_renderMatches, 100

    cycleSelected: (step) ->
      index = (@selectedCommandIndex + step) % @commandViews.length
      index = @commandViews.length - 1 if index < 0
      @setSelected index

    setSelected: (index) ->
      @selectedCommandIndex = index
      view = @commandViews[index]
      return unless view
      @selectedCommand = view.model
      @$(".selected").removeClass "selected"
      view.$el.addClass "selected"

      @scrollToSelected()

    scrollToSelected: ->
      $selected = @$ ".selected"

      top = $selected.offset().top - @$el.offset().top # + @$el.scrollTop()
      bottom = top + $selected.outerHeight()

      if bottom > @maxHeight
        @$el.scrollTop bottom - @maxHeight + @$el.scrollTop()
      else if top < 0
        @$el.scrollTop top + @$el.scrollTop()

    executeSelected: =>
      $executed = @commandViews[@selectedCommandIndex]?.$el
      return unless $executed

      $executed.addClass "active"
      setTimeout =>
        $executed.removeClass "active"
        @empty()
      , 100

      @selectedCommand?.execute()
