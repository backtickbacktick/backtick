class Options
  $hotkeyInput: $ "#hotkey"

  $importForm: $ "#import-form"
  $importInput: $ "#import-form input[type=text]"
  $importList: $ "#import-list"

  constructor: ->
    @displayHotkey()
    @setupListeners()

    $.when(@getCustomCommands(), @getCustomCommandIds())
      .then @handleCommands

  setupListeners: ->
    @$hotkeyInput.on "keypress", @onHotkeyKeypress
    @$importForm.on "submit", @onImportFormSubmit

  getCustomCommands: ->
    deferred = $.Deferred()

    chrome.storage.local.get "commands", (storage) ->
      customCommands = _.filter storage.commands, (command) -> command.custom
      deferred.resolve customCommands

    deferred

  getCustomCommandIds: ->
    deferred = $.Deferred()

    chrome.storage.sync.get "customCommandIds", (storage) ->
      deferred.resolve storage.customCommandIds or []

    deferred

  setCustomCommands: (value) => @customCommands = value

  handleCommands: (customCommands, customCommandIds) =>
    @customCommands = customCommands or []
    @customCommandIds = customCommandIds or []

    commandIndex = {}
    commandIndex[command.gistID] = command for command in customCommands
    unfetchedCommands = _.filter customCommandIds, (id) -> not commandIndex[id]

    for id in unfetchedCommands
      GitHub.fetchCommand(id).then @addCommand

    @renderCustomCommands()

  addCommand: (command) =>
    return if _.find(@customCommands, ({gistID}) -> gistID is command.gistID)
    @customCommands.push command
    @renderCustomCommands()

  syncCommand: (command) =>
    return if _.contains @customCommandIds, command.gistID
    @customCommandIds.push command.gistID
    chrome.storage.sync.set customCommandIds: @customCommandIds

  renderCustomCommands: =>
    @$importList.empty()
    commands = []
    for command in @customCommands
      commands.push $("<li>").text command.name

    @$importList.append commands

  onImportFormSubmit: (e) =>
    e.preventDefault()
    gistID = @$importInput.val()
    GitHub.fetchCommand(gistID)
      .done(@addCommand, @syncCommand)
      .fail(alert.bind(window))

  onHotkeyKeypress: (e) =>
    e.preventDefault()
    return if [13, 32].indexOf(e.which) isnt -1

    char = String.fromCharCode e.which
    @$hotkeyInput.val char
    @setHotkey char

  _setHotkey = (char) -> chrome.storage.sync.set "hotkey": char
  setHotkey: _.debounce _setHotkey, 250

  displayHotkey: ->
    chrome.storage.sync.get "hotkey", (storage) =>
      @$hotkeyInput.val storage?.hotkey or "`"

new Options