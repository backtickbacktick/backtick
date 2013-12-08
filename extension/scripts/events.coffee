class Events
  activeTab: null

  constructor: ->
    @$ = $ this
    @setupListeners()

  setupListeners: ->
    chrome.runtime.onMessage.addListener @onMessage
    chrome.runtime.onMessageExternal.addListener @onMessage

  onMessage: (req, sender) =>
    @activeTab = sender.tab
    @trigger(req.event, req.data) if req.event

  trigger: (eventName, eventData) =>
    @$.trigger eventName, eventData

  sendTrigger: (eventName, eventData) =>
    return unless @activeTab?.id
    chrome.tabs.sendMessage @activeTab.id, { event: eventName, data: eventData }

  globalTrigger: (eventName, eventData) =>
    @trigger eventName, eventData
    @sendTrigger eventName, eventData

window.Events = new Events
