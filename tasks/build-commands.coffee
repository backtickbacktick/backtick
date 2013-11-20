fs = require "fs"
_ = require "underscore"
GitHub = require "./lib/github"

class BuildCommands
  taskName: "build-commands"
  taskDescription: "Build a JSON file with the
  commands specified in commands.coffee"

  grunt: null
  markDone: null
  commands: []

  constructor: (@grunt) ->
    self = this
    @grunt.registerTask @taskName, @taskDescription, ->
      self.markDone = @async()
      self.run()

  run: ->
    commandList = require "../commands.coffee"

    partDone = _.after _.keys(commandList).length, @done
    for name, id of commandList
      GitHub.fetchGist id, (err, command) =>
        if err
          @grunt.log.error(err.message) if err
        else
          formatted = @formatCommand command
          @commands.push formatted
          @grunt.log.writeln "Added \"#{formatted.name}\" (#{formatted.gistID})"

        partDone()

  formatCommand: (command) ->
      gistID: command.id
      src: command.src

      name: command.json.name
      description: command.json.description
      link: command.json.link
      icon: command.json.icon

  done: =>
    fs.writeFile "commands.json", JSON.stringify(@commands), (err) =>
      return @grunt.log.error(err.message) if err
      @markDone()

module.exports = (grunt) ->
  new BuildCommands(grunt)