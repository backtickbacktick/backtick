define [], () ->
  App = null
  class Extension
    constructor: ->
      @listenAndTrigger()

    listenAndTrigger: ->
      return @loadApp(@listenAndTrigger.bind(this, arguments)) unless App
      return unless App.env is "extension"

      chrome.runtime.onMessage.addListener (req, sender, sendResponse) ->
        if req.event
          App.trigger(req.event, req.data)

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
