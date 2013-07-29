class Hotkey
  keys: [192, 223]
  constructor: ->
    document.addEventListener "keydown", @onKeyDown.bind(this), true

  onKeyDown: (e) ->
    return unless @keys.indexOf(e.which) > -1
    return if @isInput(document.activeElement) and not window._BACKTICK_OPEN

    e.preventDefault()
    e.stopPropagation()
    @toggleApp()

  toggleApp: ->
    chrome.runtime.sendMessage
      event: "toggle.app"
      data: window._BACKTICK_LOADED

  isInput: (element) ->
    return true if element.isContentEditable
    ["input", "textarea", "select"]
      .indexOf(element.nodeName.toLowerCase()) > -1

new Hotkey
