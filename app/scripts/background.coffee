activeTab = null
chrome.browserAction.onClicked.addListener (tab) ->
  activeTab = tab
  chrome.tabs.executeScript null, {
    code: "chrome.extension.sendRequest({ loaded: window._BACKTICK_LOADED });"
  }

chrome.extension.onRequest.addListener (req, sender, sendResponse) ->
  if req.loaded
    chrome.tabs.sendMessage activeTab.id, { event: "toggleClose" }
  else
    chrome.tabs.insertCSS null, file: "styles/main.css"
    chrome.tabs.executeScript null, file: "vendor/requirejs/require.js"
    chrome.tabs.executeScript null, file: "scripts/app.js"
