chrome.browserAction.onClicked.addListener (tab) ->
  chrome.tabs.insertCSS null, file: "styles/main.css"
  chrome.tabs.executeScript null, file: "vendor/requirejs/require.js"
  chrome.tabs.executeScript null, file: "scripts/app.js"
