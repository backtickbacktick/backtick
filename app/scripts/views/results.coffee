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
    activeCommand: null
    activeCommandIndex: 0

    initialize: ->
      @$el = App.$results
      @collection.on "sync", =>
        @createModelViews()

      App.on "command:search", @renderMatches.bind this
      App.on "command:navigateDown", (search) =>
        if search.length is 0 and not @resultsVisible
          @listAll()
        else
          @cycleActive 1

      App.on "command:navigateUp", @cycleActive.bind this, -1
      App.on "command:execute", @executeActive.bind this
      App.on "close", @empty.bind this

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
      @setActive 0

    empty: ->
      @commandViews = []
      @activeCommand = null
      @activeCommandIndex = 0
      @resultsVisible = false
      @$el.empty()

    render: ->
      @$el.empty()
      @resultsVisible = false
      return unless @commandViews.length and App.open
      $ul = $ "<ul>"
      for view in @commandViews
        view.render() unless view.isRendered()
        $ul.append view.el

      @$el.append $ul
      @resultsVisible = true
      this

    _lastSearch: ""
    _renderMatches: (search) ->
      return if @_lastSearch is search
      @_lastSearch = search
      return @listAll() if search is ""

      @commandViews = @collection.filterMatches(search)
        .map (model) -> model.view.render()

      @render()
      @setActive 0

    renderMatches: _.debounce ResultsView::_renderMatches, 100

    cycleActive: (step) ->
      index = (@activeCommandIndex + step) % @commandViews.length
      index = @commandViews.length - 1 if index < 0
      @setActive index

    setActive: (index) ->
      @activeCommandIndex = index
      view = @commandViews[index]
      return unless view
      @activeCommand = view.model
      @$(".active").removeClass "active"
      view.$el.addClass "active"

      @scrollToActive()

    scrollToActive: ->
      $active = @$ ".active"

      top = $active.outerHeight() * @activeCommandIndex - @$el.scrollTop()
      bottom = top + $active.outerHeight()
      maxHeight = parseInt @$el.css("max-height"), 10

      if bottom > maxHeight
        @$el.scrollTop bottom - maxHeight + @$el.scrollTop()
      else if top < 0
        @$el.scrollTop top + @$el.scrollTop()

    executeActive: ->
      @activeCommand?.execute()
