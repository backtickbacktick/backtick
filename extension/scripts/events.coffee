class Events
  activeTab: null

  constructor: ->
    @$ = $ this
    @setupListeners()

  setupListeners: ->
    chrome.runtime.onMessage.addListener @onMessage

  onMessage: (req, sender) =>
    @activeTab = sender.tab
    @$.trigger(req.event, req.data) if req.event

  sendTrigger: (eventName, eventData) =>
    chrome.tabs.sendMessage @activeTab?.id, { event: eventName, data: eventData }

window.Events = new Events
