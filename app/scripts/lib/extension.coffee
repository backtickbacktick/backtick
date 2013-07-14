define [
  "app"
], (
  App
) ->
  class Extension
    constructor: ->
      return unless chrome.runtime
      @listenAndTrigger()

    listenAndTrigger: ->
      chrome.runtime.onMessage.addListener (req, sender, sendResponse) ->
        App.trigger(req.event) if req.event

  new Extension
