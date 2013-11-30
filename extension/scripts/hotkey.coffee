class Hotkey
  defaultChars: ["`"]
  constructor: ->
    @hotkey = @defaultChars[0]
    chrome.storage?.sync.get "hotkey", (storage) =>
      @hotkey = storage.hotkey if storage.hotkey

    document.addEventListener "keypress", @onKeyPress, true

  onKeyPress: (e) =>
    return unless @hotkey is String.fromCharCode e.which
    return if @isInput(document.activeElement) and not window._BACKTICK_OPEN

    e.preventDefault()
    e.stopPropagation()
    @toggleApp()

  toggleApp: ->
    if chrome?.runtime
      chrome.runtime.sendMessage
        event: "toggle.app"
        data:
          loaded: window._BACKTICK_LOADED
          action: 'Hotkey'
          hotkey: @hotkey
    else
      require ["app"], (App) -> App.trigger "toggle.app"

  isInput: (element) ->
    return true if element.isContentEditable
    ["input", "textarea", "select"]
      .indexOf(element.nodeName.toLowerCase()) > -1

new Hotkey
