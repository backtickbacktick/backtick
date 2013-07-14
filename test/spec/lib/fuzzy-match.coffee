define [
  "/scripts/lib/fuzzy-match.js"
], (FuzzyMatch) ->
  describe "FuzzyMatch", ->
    describe "#matches", ->
      matches = (search) -> new FuzzyMatch("Hello World", search).matches

      it "matches full strings", ->
        matches("Hello World").should.be.true

      it "ignores case", ->
        matches("HeLLo WOrld").should.be.true

      it "ignores spaces", ->
        matches("helloworld").should.be.true

      it "matches partial strings", ->
        matches("hello").should.be.true

      it "matches strings with missing characters in-between", ->
        matches("helwo").should.be.true

      it "escapes characters", ->
        matches("hel.o").should.be.false

      it "returns false when search does not match", ->
        matches("hello planet").should.be.false

    describe "#weight", ->
      weight = (search, text = "Hello World") ->
        new FuzzyMatch(text, search).weight

      it "gives points for characters at the start of words", ->
        weight("hw").should.eq 2

      it "gives points for subsequent characters at the start of words", ->
        weight("helwor").should.eq 6

      it "treats '-', '_' and '.' as word separators", ->
        weight("hw", "Hello-World").should.eq 2
        weight("hw", "Hello_World").should.eq 2
        weight("hw", "Hello.World").should.eq 2

      it "separates words in camelCased text", ->
        weight("hw", "helloWorld").should.eq 2

      it "does not give points for characters in the middle of words", ->
        weight("er").should.eq 0

      it "does not give points for non-matches", ->
        weight("hs").should.eq 0

    describe "#wrap", ->
      wrapFunction = (char) -> "<#{char}>"
      wrap = (search, text = "Hello World") ->
        new FuzzyMatch(text, search).wrap wrapFunction

      it "wraps matching characters using the given wrapping function", ->
        wrap("herd").should.eq "<H><e>llo Wo<r>l<d>"

      it "only matches the first unmatched occurence of each character", ->
        wrap("o").should.eq "Hell<o> World"

      it "matches characters according to the order of the search", ->
        wrap("lol").should.eq "He<l>l<o> Wor<l>d"

      it "prefers to wrap leading characters of words", ->
        wrap("hll", "Hello London").should.eq "<H>e<l>lo <L>ondon"

