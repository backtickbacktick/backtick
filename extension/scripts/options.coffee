class Options
  $body: $ "body"

  $hotkeyInput: $ "#hotkey"

  $importForm: $ "#import-form"
  $importInput: $ "#import-form input[type=text]"
  $importList: $ "#import-list"

  $licenseSection: $ ".license"

  constructor: ->
    @displayHotkey()
    @setupListeners()

    @initAnalytics()

    $.when(@getCommands(), @getCustomCommandIds())
      .then @handleCommands

    @checkLicense()

  checkLicense: ->
    License.isLicensed (result) =>
      @$licenseSection.addClass(if result then "active" else "inactive")

  initAnalytics: ->
    window._gaq or= []
    window._gaq.push ["_setAccount", "UA-45140113-2"]
    window._gaq.push ["_trackPageview"]

  setupListeners: ->
    $(document)
      .on("keypress", "#hotkey", @onHotkeyKeypress)
      .on("submit", "#import-form", @onImportFormSubmit)
      .on("click", "#import-list .remove", @onClickCommandRemove)

  getCommands: ->
    deferred = $.Deferred()

    chrome.storage.local.get "commands", (storage) ->
      deferred.resolve storage.commands

    deferred

  getCustomCommandIds: ->
    deferred = $.Deferred()

    chrome.storage.sync.get "customCommandIds", (storage) ->
      deferred.resolve storage.customCommandIds or []

    deferred

  handleCommands: (commands, customCommandIds) =>
    @commands = commands or []
    @customCommandIds = customCommandIds or []

    @fetchUnfetchedCommands()
    @renderCustomCommands()

  getCustomCommands: =>
    _.filter @commands, (command) -> command.custom

  addCommand: (command) =>
    if _.any(@commands, ({gistID}) -> gistID is command.gistID)
      alert "You've already imported that command!"
      return

    command.custom = true
    @commands.push command
    chrome.storage.local.set commands: @commands

    @renderCustomCommands()

  syncCommand: (command) =>
    return if _.contains @customCommandIds, command.gistID
    @customCommandIds.push command.gistID
    chrome.storage.sync.set customCommandIds: @customCommandIds

  removeCommand: (removeID) =>
    @commands = _.filter @commands, ({gistID}) ->
      gistID isnt removeID

    @customCommandIds =_.filter @customCommandIds, (id) ->
      id isnt removeID

    chrome.storage.sync.set customCommandIds: @customCommandIds
    chrome.storage.local.set commands: @commands
    @renderCustomCommands()

  fetchUnfetchedCommands: ->
    commandIndex = {}
    commandIndex[command.gistID] = command for command in @getCustomCommands()
    unfetchedCommands = _.filter @customCommandIds, (id) -> not commandIndex[id]

    for id in unfetchedCommands
      GitHub.fetchCommand(id).then @addCommand

  renderCustomCommands: =>
    @$importList.empty()
    commands = []
    for command in @getCustomCommands()
      # TODO: Use a template for this by using a sandbox
      # http://developer.chrome.com/apps/sandboxingEval.html
      commands.push $("""
        <li class="command">
          <div class="icon" #{
            if command.icon
              "style=\"background-image: url(#{command.icon})\" "
            else
              ""
          }>
          </div>
          <div class="body">
            <span class="name">#{command.name} <small>(#{command.gistID})</small></span>
            <p class="description">#{command.description}</p>
            #{if command.link
                "<a class=\"link\" href=\"#{command.link}\">#{command.link}</a>"
              else
                ""
            }
          </div>
          <span class="remove" data-id="#{command.gistID}">Remove</span>
        </li>
      """)

    @$importList.append commands

  onClickCommandRemove: (e) =>
    id = "#{$(e.target).data("id")}"
    command = _.findWhere @getCustomCommands(), gistID: id
    if confirm "Are you sure you want to remove \"#{command.name}\""
      @removeCommand id

  onImportFormSubmit: (e) =>
    e.preventDefault()
    gistID = @$importInput.val()
    return unless gistID

    @$importInput.val ""
    @loading()
    GitHub.fetchCommand(gistID)
      .done(@addCommand, @syncCommand)
      .fail(alert.bind(window))
      .always(@loaded)

  loading: => @$body.addClass "loading"
  loaded: => @$body.removeClass "loading"

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