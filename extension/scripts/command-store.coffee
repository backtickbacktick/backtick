class CommandStore
  @COMMANDS_URL: "https://backtickio.s3.amazonaws.com/commands.json"
  @SCHEMA_VERSION: 2

  commands: []

  init: (ready) ->
    @initStorages().then @storageLoaded

  initStorages: ->
    localDeferred = $.Deferred()
    syncDeferred = $.Deferred()

    chrome.storage.local.get localDeferred.resolve.bind(localDeferred)
    chrome.storage.sync.get syncDeferred.resolve.bind(syncDeferred)

    $.when localDeferred, syncDeferred

  storageLoaded: (local, sync) =>
    # Only use commands from storage if schema version has not changed
    if local.schemaVersion is CommandStore.SCHEMA_VERSION
      @commands = local.commands or @commands
    else
      console.log "Outdated storage schema, re-fetching everything"

    @commandIndex = {}
    @commandIndex[command.gistID] = command for command in @commands

    Events.globalTrigger("load.commands", @commands) if @commands.length
    @sync()

    @fetchCustomCommands sync.customCommandIds

  importCustomCommand: (gistID) =>
    alreadyImported = _.any @commands, (command) ->
      "#{command.gistID}" is "#{gistID}"

    if alreadyImported
      return $.Deferred().reject "You've already imported that command!"

    GitHub.fetchCommand(gistID)
      .done(@addCustomCommand, @storeCommands, @syncCustomCommands)

  addCustomCommand: (command) =>
    command.custom = true
    @commands.push command

  removeCustomCommand: (gistID) =>
    @commands = _.filter @commands, (command) ->
      command.gistID isnt gistID

    @storeCommands()
    @syncCustomCommands()

  storeCommands: =>
    chrome.storage.local.set
      commands: @commands
      schemaVersion: CommandStore.SCHEMA_VERSION

  getCustomCommands: =>
    _.filter @commands, (command) -> command.custom

  fetchCustomCommands: (ids) =>
    unfetchedCommands = _.filter ids, (id) => not @commandIndex[id]
    return unless unfetchedCommands.length

    partDone = _.after unfetchedCommands.length, =>
      @storeCommands()
      Events.globalTrigger "load.commands"

    for id in unfetchedCommands
      GitHub.fetchCommand(id).then (command) =>
        @addCustomCommand command
        partDone()

  sync: ->
    $.getJSON("#{CommandStore.COMMANDS_URL}?t=#{Date.now()}")
      .done((response) =>
        wasFirstSync = @commands.length is 0

        if response.length
          @commands = response.concat @getCustomCommands()
          @storeCommands()

          eventName = if wasFirstSync then "load.commands" else "sync.commands"
          Events.globalTrigger eventName, @commands
      )
      .fail(console.log.bind(console, "Error fetching commands"))

  syncCustomCommands: =>
    chrome.storage.sync.set
      customCommandIds: _.pluck @getCustomCommands(), "gistID"

window.CommandStore = new CommandStore