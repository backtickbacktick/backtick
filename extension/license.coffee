class License
  LICENSE_ID: "fdocciflgajbbcgmnfifnmoamjgiefip"

  isLicensed: (callback) ->
    chrome.runtime.sendMessage @LICENSE_ID, "ping", (response) ->
      callback !!response

window.License = new License