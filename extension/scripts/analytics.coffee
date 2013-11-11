class Analytics
  id: "UA-45140113-2"

  constructor: ->
    window._gaq or= []
    window._gaq.push ["_setAccount", @id]

  trackEvent: (category, action, label, value) ->
    eventArray = ["_trackEvent", category, action]
    eventArray.push(label) if label
    eventArray.push(parseInt(value, 10)) if value

    window._gaq.push eventArray

window.Analytics = new Analytics