class GitHub
  @API_URL: "https://api.github.com"

  fetchCommand: (id) ->
    deferred = $.Deferred()

    @fetchGist(id)
      .done((gist) =>
        command = @commandFromGist gist
        return deferred.reject(command.error) if command.error
        deferred.resolve command
      )
      .error ->
        deferred.reject("Unable to get Gist with id #{id}")

    deferred

  fetchGist: (id) ->
    $.getJSON("#{GitHub.API_URL}/gists/#{id}?t=#{Date.now()}")
      .error(-> console.error "Unable to get Gist with id #{id}")

  commandFromGist: (gist) ->
    return { error: "Missing command.js" } unless gist?.files?["command.js"]
    return { error: "Missing command.json" } unless gist?.files?["command.json"]

    try
      json = JSON.parse gist.files["command.json"].content
    catch e
      return { error: "The command.json file is not a valid JSON file" }

    return { error: "Command name missing" } unless json.name
    return { error: "Command description missing" } unless json.description

    {
      gistID: gist.id
      name: json.name
      description: json.description
      icon: json.icon
      link: json.link
      src: gist.files["command.js"].raw_url
    }

window.GitHub = new GitHub