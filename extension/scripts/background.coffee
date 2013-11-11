class Background
  events:
    "toggle.app": "toggleApp"
    "ready.app": "initApp"
    "open.settings": "openSettings"
    "fetch.commands": "fetchCommands"
    "track": "trackScriptEvent"

  constructor: ->
    # Replace strings with the actual methods
    @events[eventName] = @[method] for eventName, method of @events

    @initAnalytics()
    @setupListeners()

  initAnalytics: ->
    window._gaq or= []
    window._gaq.push ["_setAccount", "UA-45140113-2"]

  setupListeners: ->
    chrome.browserAction.onClicked.addListener @onClickBrowserAction
    window.Events.$.on @events

  onClickBrowserAction: (tab) =>
    chrome.tabs.executeScript null, {
      code: "chrome.runtime.sendMessage({
        event: 'toggle.app',
        data: { loaded: window._BACKTICK_LOADED, action: 'Click' }
      });"
    }

  toggleApp: (e, data) =>
    eventName = ""

    if data.loaded
      window.Events.sendTrigger "toggle.app"
      eventName = "Toggled App"
    else
      chrome.tabs.insertCSS null, file: "styles/container.css"
      chrome.tabs.executeScript null, file: "vendor/requirejs/require.js"
      chrome.tabs.executeScript null, file: "scripts/app.js"

      eventName = "Loaded App"

    @trackEvent eventName, data.action, data.hotkey

  initApp: =>
    window.CommandStore.init()
    @checkLicense()

  openSettings: =>
    chrome.tabs.create url: "extension/options.html"
    @trackEvent "Open Settings", "Click"

  fetchCommands: (e, command) =>
    $.ajax
      url: command.src
      success: (response) =>
        window.Events.sendTrigger "fetched.commands", response
        @trackEvent "Executed Command", command.name, command.gistID

      error: window.Events.sendTrigger.bind(window.Events,
        "fetchError.commands", command)

  trackScriptEvent: (e, data) =>
    @trackEvent data.category, data.action, data.label, data.value

  trackEvent: (category, action, label, value) ->
    eventArray = ["_trackEvent", category, action]
    eventArray.push(label) if label
    eventArray.push(parseInt(value, 10)) if value

    window._gaq.push eventArray

  checkLicense: ->
    window.License.isLicensed (result) ->
      return if result
      window.Events.sendTrigger "unlicensedUse.app"

window.Background = new Background