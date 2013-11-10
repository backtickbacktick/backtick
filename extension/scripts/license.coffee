class License
  I_AM_A_PIRATE: false
  LICENSE_ID: "fdocciflgajbbcgmnfifnmoamjgiefip"

  isLicensed: (callback) ->
    chrome.runtime.sendMessage @LICENSE_ID, "ping", (response) =>
      callback @I_AM_A_PIRATE or !!response

window.License = new License
