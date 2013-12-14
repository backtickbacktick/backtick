class Background
  JAVASCRIPT_URL_REGEXP: /^javascript:/
  events:
    "toggle.app": "toggleApp"
    "ready.app": "initApp"
    "open.settings": "openSettings"
    "execute.commands": "executeCommand"
    "add.commands": "addCommand"
    "track": "trackScriptEvent"

  constructor: ->
    # Replace strings with the actual methods
    @events[eventName] = @[method] for eventName, method of @events

    @setupListeners()

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

    window.Analytics.trackEvent eventName, data.action, data.hotkey

  initApp: =>
    window.CommandStore.init()
    @checkLicense()

  openSettings: =>
    chrome.tabs.create url: "extension/options.html"
    window.Analytics.trackEvent "Open Settings", "Click"

  convertCommandSource: (url) ->
    if @JAVASCRIPT_URL_REGEXP.test url
      url = url.replace @JAVASCRIPT_URL_REGEXP, ""
      try
        url = decodeURIComponent url
      catch e
        # Do nothing

    "javascript:#{url}"

  executeCommand: (e, command) =>
    $.ajax(
      url: command.src
      success: (response) =>
        chrome.tabs.update null, url: @convertCommandSource(response)

        window.Events.sendTrigger "executed.commands", command
        window.Analytics.trackEvent("Executed Command", command.name,
          command.gistID)

      error: window.Events.sendTrigger.bind(window.Events,
        "fetchError.commands", command)
    )

  addCommand: (e, gistID) =>
    window.CommandStore.importCustomCommand(gistID)
      .done((command) ->
        window.Events.sendTrigger "added.commands", command
        window.Events.globalTrigger "sync.commands", window.CommandStore.commands
      )
      .fail((error) ->
        window.Events.sendTrigger "addError.commands", error
      )

  trackScriptEvent: (e, data) =>
    window.Analytics.trackEvent(data.category, data.action,
      data.label, data.value)

  checkLicense: ->
    window.License.isLicensed (result) ->
      return if result
      window.Events.sendTrigger "unlicensedUse.app"

window.Background = new Background