require ["/extension/command-store.js"], ->
  describe "CommandStore", ->
    describe "#mergeCommands", ->
      beforeEach ->
        CommandStore.commands = []

      it "adds commands", ->
        expect(-> CommandStore.commands.length).to.increase.when ->
          CommandStore.mergeCommands [{gistID: 1, name: "Test"}]

      it "does not add already existing commands", ->
        CommandStore.commands = [{gistID: 1, name: "Test"}]
        expect(-> CommandStore.commands.length).to.not.change.when ->
          CommandStore.mergeCommands [{gistID: 1, name: "Test"}]

      it "updates existing commands", ->
       CommandStore.commands = [{gistID: 1, name: "Test"}]
       expect(-> CommandStore.commands[0].name).to.change.to("Changed").when ->
         CommandStore.mergeCommands [{gistID: 1, name: "Changed"}]

      it "both adds and updates commands", ->
        CommandStore.commands = [{gistID: 1, name: "Test"}]
        updatedCommands = [
          {gistID: 1, name: "Changed"}
          {gistID: 2, name: "Test2"}
        ]

        CommandStore.mergeCommands updatedCommands
        CommandStore.commands.should.deep.equal updatedCommands


