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
      if @supported
        chrome.runtime.sendMessage { event: eventName, data: eventData }
      else
        App or= require "app"
        App.trigger eventName, eventData

  new Extension
