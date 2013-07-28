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
    commandViews: []
    activeCommand: null
    activeCommandIndex: 0

    initialize: ->
      @$el = App.$results
      @collection.on "sync", =>
        @createModelViews()

      App.on "command:search", @renderMatches.bind this
      App.on "command:navigateDown", @cycleActive.bind this, 1
      App.on "command:navigateUp", @cycleActive.bind this, -1
      App.on "command:execute", @executeActive.bind this
      App.on "close", @empty.bind this

    createModelViews: ->
      @collection.each (command) =>
        view = new CommandView model: command
        command.view = view
        @commandViews.push view

    remove: ->
      @$el.remove()

    empty: ->
      @commandViews = []
      @activeCommand = null
      @activeCommandIndex = 0
      @$el.empty()

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
        .map (model) -> model.view.render()

      @render()
      @setActive @commandViews[0]

    renderMatches: _.debounce ResultsView::_renderMatches, 100

    cycleActive: (step) ->
      @activeCommandIndex = (@activeCommandIndex + step) % @commandViews.length
      @activeCommandIndex = @commandViews.length - 1 if @activeCommandIndex < 0
      @setActive @commandViews[@activeCommandIndex]

    setActive: (view) ->
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
