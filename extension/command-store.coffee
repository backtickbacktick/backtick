class CommandStore
  @COMMANDS_ENDPOINT: "http://api.backtick.io/commands"

  commands: []
  lastSync: null

  init: (ready) ->
    @initStorages().then @storageLoaded

  initStorages: ->
    localDeferred = $.Deferred()
    syncDeferred = $.Deferred()

    chrome.storage.local.get localDeferred.resolve.bind(localDeferred)
    chrome.storage.sync.get syncDeferred.resolve.bind(syncDeferred)

    $.when localDeferred, syncDeferred

  storageLoaded: (local, sync) =>
    @commands = local.commands or @commands
    @lastSync = local.lastSync or @lastSync

    @commandIndex = {}
    @commandIndex[command.gistID] = command for command in @commands

    @trigger("load.commands", @commands)  if @commands.length
    @sync()

    @getCustomCommands sync.customCommandIds

  storeCommands: ->
    chrome.storage.local.set {commands: @commands, lastSync: @lastSync}

  mergeCommands: (updatedCommands) ->
    for command in updatedCommands
      if @commandIndex[command.gistID]
        $.extend @commandIndex[command.gistID], command
      else
        @commands.push command

  getCustomCommands: (ids) =>
    unfetchedCommands = _.filter ids, (id) => not @commandIndex[id]

    for id in unfetchedCommands
      GitHub.fetchCommand(id).then (command) =>
        command.custom = true
        @mergeCommands [command]
        @storeCommands()

  sync: ->
    params = {}
    params["updatedSince"] = @lastSync if @lastSync

    $.getJSON(CommandStore.COMMANDS_ENDPOINT, params)
      .done((response) =>
        wasFirstSync = @commands.length is 0

        if response.length
          @mergeCommands response

          # Response is sorted by ascending updatedAt
          @lastSync = response[response.length - 1].updatedAt

          @storeCommands()
          eventName = if wasFirstSync then "load.commands" else "sync.commands"
          @trigger eventName, @commands
      )
      .fail(console.log.bind(console, "Error fetching commands"))

  trigger: (eventName, eventData) ->
    window.Events.sendTrigger eventName, eventData

  requestFileSystem: (
    window.requestFileSystem ||
    window.webkitRequestFileSystem
  ).bind(window)

window.CommandStore = new CommandStore