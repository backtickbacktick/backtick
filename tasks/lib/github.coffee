request = require "request"
githubAuth = require "../../auth/github"

class GitHub
  fetchGist: (gistID, callback) ->
    request.get(
      url: "https://api.github.com/gists/#{gistID}" +
            "?client_id=#{githubAuth.clientID}" +
            "&client_secret=#{githubAuth.clientSecret}"
      headers:
        "User-Agent": "Backtick/1.0"
      json: true
    , (err, res, body) ->
      return callback err if err

      code = res.statusCode
      return callback(new Error "Missing Gist") if code is 404
      return callback(new Error body?.message or body) unless code is 200

      jsonFile = body.files?["command.json"]
      return callback(new Error "Missing JSON") unless jsonFile

      try
        json = JSON.parse body.files["command.json"].content
      catch exception
        return callback new Error "Unparsable JSON"

      callback err,
        json: json
        id: body.id
        src: body.files["command.js"]?.raw_url
    )

module.exports = new GitHub
