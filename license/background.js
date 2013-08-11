chrome.runtime.onConnectExternal.addListener(function(port) {
  port.onMessage.addListener(function(msg) {
    if (msg) port.postMessage(true);
  });
});