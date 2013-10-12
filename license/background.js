chrome.runtime.onMessageExternal.addListener(function(message, sender, respond) {
  respond(true);
});