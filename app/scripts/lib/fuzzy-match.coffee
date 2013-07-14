define ["underscore"], (_) ->
  class FuzzySearch
    @WEIGHT_SEPARATOR_REGEX: /(\_|\-|\.)/gi

    matches: false
    weight: 0
    weightedCharIndexes: null

    constructor: (@text, @search) ->
      @weightedCharIndexes = []
      @searchChars = @search.toLowerCase().replace(" ", "").split ""
      @matches = @_match()
      @weight = @_weight()

    _match: ->
      chars = _.clone @searchChars

      # Escape non alphanumerical chars
      for char, i in chars
        if /\W/.test char
          chars[i] = "\\#{char}"

      new RegExp(chars.join(".*"), "gi").test @text

    # A weighting algorithm that counts the number of characters from the given
    # search string that matches the first characters of words in the given
    # text. This allows for acronym searches such as: ASE -> A Simple Example.
    _weight: ->
      return 0 unless @matches
      chars = _.clone @searchChars
      weight = 0
      offset = 0

      text = @text
         # Replace all separators with spaces
        .replace(FuzzySearch::WEIGHT_SEPARATOR_REGEX, " ")
          # Add spaces to CamelCased text
        .replace(/([^ ])?[A-Z]/g, (match, before) ->
          return match unless before
          "#{match[0]} #{match[1]}"
        )
        .toLowerCase()

      while (char = chars.shift()) isnt undefined
        i = text.substring(offset).search \
          new RegExp("(^| )#{char}", "gi")

        if i is -1
          i = text.indexOf char, offset
        else
          @weightedCharIndexes.push i + offset + if i is 0 then 0 else 1
          weight++

        offset += i + 1

        # Skip over spaces
        offset += /^ /.test(text.substring(offset - 1))

      weight

    # Wrap matched characters using the given wrap callback method
    wrap: (wrapCallback) ->
      chars = _.clone @searchChars
      weightedIndexes = _.clone @weightedCharIndexes
      wrapCharTable = {}

      offset = 0
      lowerCased = @text.toLowerCase()

      while (char = chars.shift()) isnt undefined
        if char is lowerCased[weightedIndexes[0]]
          i = weightedIndexes.shift()
          wrapCharTable[i] = true
        else
          i = lowerCased.indexOf char, offset
          while wrapCharTable[i]
            i = lowerCased.indexOf char, i + 1

          wrapCharTable[i] = true
          offset = i + 1

      matchString = ""
      for i in [0...@text.length]
        if wrapCharTable[i]
          matchString += wrapCallback @text[i]
        else
          matchString += @text[i]

      matchString
