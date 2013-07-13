define [
  "/scripts/lib/fuzzy-search.js"
], (FuzzySearch) ->
  describe "FuzzySearch", ->
    describe "#match", ->
      match = (search) -> FuzzySearch.match search, "Hello World"

      it "matches full strings", ->
        match("Hello World").should.be.true

      it "ignores case", ->
        match("HeLLo WOrld").should.be.true

      it "ignores spaces", ->
        match("helloworld").should.be.true

      it "matches partial strings", ->
        match("hello").should.be.true

      it "matches strings with missing characters in-between", ->
        match("helwo").should.be.true

      it "escapes characters", ->
        match("hel.o").should.be.false

      it "returns false when search does not match", ->
        match("hello planet").should.be.false

    describe "#weight", ->
      weight = (search, text = "Hello World") -> FuzzySearch.weight search, text

      it "gives points for characters at the start of words", ->
        weight("hw").should.eq 2

      it "does not give points for characters in the middle of words", ->
        weight("er").should.eq 0

      it "gives points for subsequent characters at the start of words", ->
        weight("helwor").should.eq 6

      it "treats '-', '_' and '.' as word separators", ->
        weight("hw", "Hello-World").should.eq 2
        weight("hw", "Hello_World").should.eq 2
        weight("hw", "Hello.World").should.eq 2

      it "separates words in camelCased text", ->
        weight("hw", "helloWorld").should.eq 2

    describe "#wrap", ->
      wrapFunction = (char) -> "<#{char}>"
      wrap = (search) -> FuzzySearch.wrap search, "Hello World", wrapFunction

      it "wraps matching characters using the given wrapping function", ->
        wrap("herd").should.eq "<H><e>llo Wo<r>l<d>"

      it "only matches the first unmatched occurence of each character", ->
        wrap("o").should.eq "Hell<o> World"

      it "matches characters according to the order of the search", ->
        wrap("lol").should.eq "He<l>l<o> Wor<l>d"

