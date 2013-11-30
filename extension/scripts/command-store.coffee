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

    @trigger("load.commands", @commands)  if @commands.length
    @sync()

    @getCustomCommands sync.customCommandIds

  storeCommands: ->
    chrome.storage.local.set
      commands: @commands
      schemaVersion: CommandStore.SCHEMA_VERSION

  getCustomCommands: (ids) =>
    unfetchedCommands = _.filter ids, (id) => not @commandIndex[id]

    for id in unfetchedCommands
      GitHub.fetchCommand(id).then (command) =>
        command.custom = true
        @commands.push command
        @storeCommands()

  sync: ->
    $.getJSON("#{CommandStore.COMMANDS_URL}?t=#{Date.now()}")
      .done((response) =>
        wasFirstSync = @commands.length is 0

        if response.length
          @commands = _.filter @commands, (command) -> command.custom
          @commands = @commands.concat response
          @storeCommands()

          eventName = if wasFirstSync then "load.commands" else "sync.commands"
          @trigger eventName, @commands
      )
      .fail(console.log.bind(console, "Error fetching commands"))

  trigger: (eventName, eventData) ->
    window.Events.sendTrigger eventName, eventData

window.CommandStore = new CommandStore