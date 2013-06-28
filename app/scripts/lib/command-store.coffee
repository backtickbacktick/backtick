define [
  "underscore"
  "backbone"
], (_, Backbone) ->
  class CommandStore
    commands: null
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

    onLoadError: console.log.bind("error", console)

    readFile: (file) ->
      reader = new FileReader
      reader.readAsText file
      self = this
      reader.onloadend = ->
        self.commands = JSON.parse(@result) if @result
        self.trigger "initialised"

    storeCommands: ->
      @fileEntry.createWriter ((fileWriter) =>
        blob = new Blob [JSON.stringify @commands], type: "application/json"

        fileWriter.write blob
        fileWriter.onwriteend = console.log.bind console, "Successfully wrote file"
        fileWriter.onerror = console.log.bind console, "Error writing file"
      ), console.log.bind(console, "Error creating writer")

    init: ->
      return @on "loaded", @init.bind(this, arguments) unless @fs
      @fs.root.getFile "commands.json", { create: true }, (fileEntry) =>
        @fileEntry = fileEntry
        fileEntry.file @readFile.bind(this), @onLoadError.bind(this)

    sync: ->
      return _.defer @trigger.bind(this, "synced") if @commands

      $.getJSON "http://#{location.hostname}:4100/commands", (response) =>
        @commands = response
        @trigger "synced"
        @storeCommands()

    requestFileSystem: (
      window.requestFileSystem ||
      window.webkitRequestFileSystem
    ).bind(window)

  new CommandStore