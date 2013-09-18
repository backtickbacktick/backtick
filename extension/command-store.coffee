class CommandStore
  @COMMANDS_ENDPOINT: "http://dev.api.backtick.io/commands"

  commands: []
  lastSync: null

  init: (ready) ->
    chrome.storage.local.get @storageLoaded

  storageLoaded: (storage) =>
    @commands = storage.commands or @commands
    @lastSync = storage.lastSync or @lastSync
    @trigger("load.commands", @commands)  if @commands.length
    @sync()

  storeCommands: ->
    chrome.storage.local.set {commands: @commands, lastSync: @lastSync}

  mergeCommands: (updatedCommands) ->
    commandsMap = {}
    commandsMap[command.gistID] = command for command in @commands

    for command in updatedCommands
      if commandsMap[command.gistID]
        $.extend commandsMap[command.gistID], command
      else
        @commands.push command

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