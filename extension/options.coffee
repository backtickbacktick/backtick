class Options
  constructor: ->
    @$hotkeyInput = $ "#hotkey"
    @displayHotkey()

    @$hotkeyInput.on "keypress", (e) =>
      e.preventDefault()
      return if [13, 32].indexOf(e.which) isnt -1

      char = String.fromCharCode e.which
      @$hotkeyInput.val char
      @setHotkey char

  _setHotkey = (char) -> chrome.storage.sync.set "hotkey": char
  setHotkey: _.debounce _setHotkey, 100

  displayHotkey: ->
    chrome.storage.sync.get "hotkey", (storage) =>
      @$hotkeyInput.val storage?.hotkey or "`"

new Options