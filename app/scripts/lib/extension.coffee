define [
  "app"
], (
  App
) ->
  class Extension
    supported: !!chrome.runtime
    constructor: ->
      @listenAndTrigger()

    listenAndTrigger: ->
      return unless @supported
      chrome.runtime.onMessage.addListener (req, sender, sendResponse) ->
        App or= require "app"
        if req.event
          App.trigger(req.event, req.data)

    trigger: (eventName, eventData) ->
      return unless @supported
      chrome.runtime.sendMessage { event: eventName, data: eventData }

  new Extension
