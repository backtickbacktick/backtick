require [
  "handlebars"
  "lib/fuzzy-search"
], (
  Handlebars
  FuzzySearch
) ->
  helpers =
    highlightMatches: (text, search) ->
      result = FuzzySearch.wrap search, text, (match) ->
        "<span class=\"_bt-match\">#{match}</span>"

      new Handlebars.SafeString result

    prettyUrl: (url) ->
      url.replace /^((http|https):\/\/)?(www.)?/, ""

  Handlebars.registerHelper(name, helper) for name, helper of helpers
