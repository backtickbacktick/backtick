class CommandStore
  commands: []
  lastSync: null
  fileEntry: null

  init: (ready) ->
    @requestFileSystem(
      window.PERSISTENT
      10 * 1024 * 1024
      @onFSLoad.bind this
      @onLoadError.bind this
    )

  onFSLoad: (fs) ->
    @fs = fs
    @fs.root.getFile "commands.json", { create: true }, ((fileEntry) =>
      @fileEntry = fileEntry
      fileEntry.file @readFile.bind(this), @onLoadError.bind(this)
    ), console.log.bind(console, "Error loading file")

  onLoadError: console.log.bind(console, "Error")

  readFile: (file) ->
    reader = new FileReader
    reader.readAsText file
    self = this
    reader.onloadend = ->
      self.parseFile @result
      self.trigger("load.commands", self.commands) if self.commands.length
      self.sync()

  parseFile: (content) ->
    return unless content

    try
      json = JSON.parse content
    catch e
      console.log "Error parsing file"
      return

    @commands = json.commands
    @lastSync = json.lastSync

  storeCommands: ->
    @fileEntry.createWriter ((fileWriter) =>
      json = JSON.stringify {
        commands: @commands
        lastSync: @lastSync
      }
      blob = new Blob [json], type: "application/json"

      fileWriter.write blob
      fileWriter.onwriteend = \
        console.log.bind console, "Successfully wrote file"
      fileWriter.onerror = console.log.bind console, "Error writing file"
    ), console.log.bind(console, "Error creating writer")

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

    $.getJSON("http://dev.api.backtick.io/commands", params)
      .success((response) =>
        wasFirstSync = @commands.length is 0
        if response.length
          @mergeCommands response

          # Response is sorted by ascending updatedAt
          @lastSync = response[response.length - 1].updatedAt

          @storeCommands()
          event = if wasFirstSync then "load.commands" else "sync.commands"
          @trigger event, @commands
      )
      .error(console.log.bind(console, "Error fetching commands"))

  trigger: (eventName, eventData) ->
    window.Events.sendTrigger eventName, eventData

  requestFileSystem: (
    window.requestFileSystem ||
    window.webkitRequestFileSystem
  ).bind(window)

window.CommandStore = new CommandStore