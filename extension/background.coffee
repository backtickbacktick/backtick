# TOOO: Clean up and refactor this into a class
activeTab = null

window.Events = {
  sendTrigger: (eventName, eventData) ->
    chrome.tabs.sendMessage activeTab?.id, { event: eventName, data: eventData }
}

window._gaq or= []
window._gaq.push ["_setAccount", "UA-45140113-2"]

Events.$ = $ Events
chrome.runtime.onMessage.addListener (req, sender) ->
  activeTab = sender.tab
  window.Events.$.trigger(req.event, req.data) if req.event

chrome.browserAction.onClicked.addListener (tab) ->
  activeTab = tab
  chrome.tabs.executeScript null, {
    code: "chrome.runtime.sendMessage({
      event: 'toggle.app',
      data: { loaded: window._BACKTICK_LOADED, action: 'Click' }
    });"
  }

Events.$.on
  "toggle.app": (e, data) ->
    if data.loaded
      Events.sendTrigger "toggle.app"
      trackEvent "Toggled App", data.action, data.hotkey
    else
      chrome.tabs.insertCSS null, file: "styles/container.css"
      chrome.tabs.executeScript null, file: "vendor/requirejs/require.js"
      chrome.tabs.executeScript null, file: "scripts/app.js"

      trackEvent "Loaded App", data.action, data.hotkey

  "ready.app": ->
    CommandStore.init()
    checkLicense()

  "open.settings": ->
    chrome.tabs.create url: "options.html"
    trackEvent "Open Settings", "Click"

  "execute.commands": (e, command) ->
    $.ajax
      url: command.src
      success: (response) ->
        url = "javascript:#{response}"
        chrome.tabs.update activeTab.id, {url: url}
        Events.sendTrigger "executed.commands", command

        trackEvent "Executed Command", command.name, command.gistID

      error: Events.sendTrigger.bind Events, "executionError.commands", command

  "track": (e, data) ->
    trackEvent data.category, data.action, data.label, data.value

checkLicense = ->
  License.isLicensed (result) ->
    return if result
    Events.sendTrigger "unlicensedUse.app"

trackEvent = (category, action, label, value) ->
  eventArray = ["_trackEvent", category, action]
  eventArray.push(label) if label
  eventArray.push(parseInt(value, 10)) if value

  window._gaq.push eventArray
