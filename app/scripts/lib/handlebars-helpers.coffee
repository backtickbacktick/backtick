require [
  "handlebars"
], (
  Handlebars
) ->
  helpers =
    highlightMatches: (match) ->
      result = match.wrap (match) ->
        "<span class=\"_bt-match\">#{match}</span>"

      new Handlebars.SafeString result

    prettyUrl: (url) ->
      url.replace /^((http|https):\/\/)?(www.)?/, ""

  Handlebars.registerHelper(name, helper) for name, helper of helpers
