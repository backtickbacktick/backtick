define [
  "views/base"
  "lib/fuzzy-search"
], (
  BaseView
  FuzzySearch
) ->
  class CommandView extends BaseView
    tagName: "li"

    render: ->
      @$el.append @model.get "name"
      this

    highlightMatches: (search) ->
      @$el.html FuzzySearch.wrap search, @model.get("name"), (match) ->
        "<span class=\"match\">#{match}</span>"
      this


