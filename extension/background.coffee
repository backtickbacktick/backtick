# TOOO: Clean up and refactor this into a class
activeTab = null

window.Events = {
  sendTrigger: (eventName, eventData) ->
    chrome.tabs.sendMessage activeTab?.id, { event: eventName, data: eventData }
}

Events.$ = $ Events
chrome.runtime.onMessage.addListener (req, sender) ->
  activeTab = sender.tab
  window.Events.$.trigger(req.event, req.data) if req.event

chrome.browserAction.onClicked.addListener (tab) ->
  activeTab = tab
  chrome.tabs.executeScript null, {
    code: "chrome.runtime.sendMessage({
      event: 'toggle.app',
      data: window._BACKTICK_LOADED
    });"
  }

Events.$.on
  "toggle.app": (e, loaded) ->
    if loaded
      Events.sendTrigger "toggle.app"
    else
      chrome.tabs.insertCSS null, file: "styles/container.css"
      chrome.tabs.executeScript null, file: "vendor/requirejs/require.js"
      chrome.tabs.executeScript null, file: "scripts/app.js"

  "ready.app": ->
    CommandStore.init()
    checkLicense()

  "open.settings": ->
    chrome.tabs.create url: "options.html"

  "execute.commands": (e, command) ->
    $.ajax
      url: command.src
      success: (response) ->
        url = "javascript:#{response}"
        chrome.tabs.update activeTab.id, {url: url}
        Events.sendTrigger "executed.commands", command

      error: Events.sendTrigger.bind Events, "executionError.commands", command

checkLicense = ->
  License.isLicensed (result) ->
    return if result
    Events.sendTrigger "unlicensedUse.app"
