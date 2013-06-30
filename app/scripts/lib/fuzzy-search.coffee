define ["underscore"], (_) ->
  class FuzzySearch
    WEIGHT_SEPARATOR_REGEX = /(\_|\-|\.)/gi

    match: (search, text) ->
      chars = _splitChars search

      # Escape non alphanumerical chars
      for char, i in chars
        if /\W/.test char
          chars[i] = "\\#{char}"

      new RegExp(chars.join(".*"), "gi").test text

    # A weighting algorithm that counts the number of characters from the given
    # search string that matches the first characters of words in the given
    # text. This allows for acronym searches such as: ASE -> A Simple Example.
    weight: (search, text) ->
      chars = _splitChars search
      weight = 0
      offset = 0

      # Replace all separators with spaces
      text = text.replace(WEIGHT_SEPARATOR_REGEX, " ")
      # Add spaces to CamelCased text
      text = text.replace(/([^ ])?[A-Z]/g, (match, before) ->
        return match unless before
        "#{match[0]} #{match[1]}"
      )

      while (char = chars.shift()) isnt undefined
        i = text.substring(offset).search \
          new RegExp("(^| )#{char}", "gi")

        if i is -1
          i = text.toLowerCase().indexOf char, offset
        else
          weight++

        offset += i + 1

        # Skip over spaces
        offset += /^ /.test(text.substring(offset - 1))

      weight

    # Wrap matched characters using the given wrap callback method
    wrap: (search, text, wrapCallback) ->
      chars = _splitChars search

      offset = 0
      matchString = ""
      lowerCased = text.toLowerCase()

      while (char = chars.shift()) isnt undefined
        i = lowerCased.indexOf char, offset
        continue if i is -1
        matchString += \
          "#{text.substr offset, i - offset}#{wrapCallback text.substr(i, 1)}"
        offset = i + 1

      matchString += text.substr offset

    _splitChars = (text) ->
      _.clone _memoizedSplitChars(text)

    _memoizedSplitChars = _.memoize(
      (text) ->
        text
          .toLowerCase()
          .replace(" ", "")
          .split ""
    )

  new FuzzySearch
