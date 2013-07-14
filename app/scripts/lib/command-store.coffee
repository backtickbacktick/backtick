define [
  "underscore"
  "backbone"
  "config"
], (
  _
  Backbone
  Config
) ->
  class CommandStore
    commands: []
    lastSync: null
    fileEntry: null

    constructor: ->
      _.extend this, Backbone.Events
      @requestFileSystem(
        window.PERSISTENT
        10 * 1024 * 1024
        @onLoad.bind this
        @onLoadError.bind this
      )

      @on "initialised", @sync.bind this

    onLoad: (fs) ->
      @fs = fs
      @trigger "loaded"

    onLoadError: console.log.bind(console, "error")

    readFile: (file) ->
      reader = new FileReader
      reader.readAsText file
      self = this
      reader.onloadend = ->
        self.parseFile @result
        self.trigger "initialised"

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
          _.extend commandsMap[command.gistID], command
        else
          @commands.push command

    init: ->
      return @on "loaded", @init.bind(this, arguments) unless @fs
      @fs.root.getFile "commands.json", { create: true }, ((fileEntry) =>
        @fileEntry = fileEntry
        fileEntry.file @readFile.bind(this), @onLoadError.bind(this)
      ), console.log.bind(console, "Error loading file")

    sync: ->
      params = {}
      params["updatedSince"] = @lastSync if @lastSync

      $.getJSON("#{Config.API_URL}/commands", params)
        .success((response) =>
          if response.length
            @mergeCommands response
            @lastSync = _.last(response).updatedAt # Response is sorted by
                                                   # ascending updatedAt
            @storeCommands()

          @trigger "synced"
        )
        .error(console.log.bind(console, "Error fetching commands"))

    requestFileSystem: (
      window.requestFileSystem ||
      window.webkitRequestFileSystem
    ).bind(window)

  new CommandStore