define [
  "/scripts/lib/fuzzy-search.js"
], (FuzzySearch) ->
  describe "FuzzySearch", ->
    it "loads", ->
      FuzzySearch.should.exist
