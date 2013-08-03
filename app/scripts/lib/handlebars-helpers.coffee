require [
  "handlebars"
], (
  Handlebars
) ->
  helpers =
    highlightMatches: (match) ->
      result = match.wrap (match) ->
        "<span class=\"match\">#{match}</span>"

      new Handlebars.SafeString result

    prettyUrl: (url) ->
      url.replace(/^((http|https):\/\/)?(www.)?/, "")
         .replace(/\/$/, "")
         .replace(/\.html$/, "")

  Handlebars.registerHelper(name, helper) for name, helper of helpers
