define [], () ->
  App = null
  class Extension
    constructor: ->
      @listenAndTrigger()

    listenAndTrigger: =>
      return @loadApp(@listenAndTrigger) unless App
      return unless App.env is "extension"

      chrome.runtime.onMessage.addListener (req, sender, sendResponse) ->
        App.trigger(req.event, req.data) if req.event

    trigger: (eventName, eventData) ->
      return @loadApp(@trigger.bind(this, eventName, eventData)) unless App

      if App.env is "extension"
        chrome.runtime.sendMessage { event: eventName, data: eventData }
      App.trigger eventName, eventData

    loadApp: (callback) ->
      require ["app"], (_App) ->
        App = _App
        callback()

  new Extension
