class Options
  $body: $ "body"

  $hotkeyInput: $ "#hotkey"

  $importForm: $ "#import-form"
  $importInput: $ "#import-form input[type=text]"
  $importList: $ "#import-list"

  $licenseSection: $ ".license"

  constructor: ->
    @displayHotkey()
    @setupListeners()
    @initAnalytics()
    @checkLicense()

    CommandStore.init()
    Events.$.on "load.commands", @renderCommands

  checkLicense: ->
    License.isLicensed (result) =>
      @$licenseSection.addClass(if result then "active" else "inactive")

  initAnalytics: ->
    window._gaq or= []
    window._gaq.push ["_setAccount", "UA-45140113-2"]
    window._gaq.push ["_trackPageview"]

  setupListeners: ->
    $(document)
      .on("keypress", "#hotkey", @onHotkeyKeypress)
      .on("submit", "#import-form", @onImportFormSubmit)
      .on("click", "#import-list .remove", @onClickCommandRemove)

  renderCommands: =>
    @$importList.empty()
    commands = []
    for command in CommandStore.getCustomCommands()
      # TODO: Use a template for this by using a sandbox
      # http://developer.chrome.com/apps/sandboxingEval.html
      commands.push $("""
        <li class="command">
          <div class="icon" #{
            if command.icon
              "style=\"background-image: url(#{command.icon})\" "
            else
              ""
          }>
          </div>
          <div class="body">
            <span class="name">#{command.name} <small>(#{command.gistID})</small></span>
            <p class="description">#{command.description}</p>
            #{if command.link
                "<a class=\"link\" href=\"#{command.link}\">#{command.link}</a>"
              else
                ""
            }
          </div>
          <span class="remove" data-id="#{command.gistID}">Remove</span>
        </li>
      """)

    @$importList.append commands

  onClickCommandRemove: (e) =>
    id = "#{$(e.target).data("id")}"
    command = _.findWhere CommandStore.getCustomCommands(), gistID: id
    if confirm "Are you sure you want to remove \"#{command.name}\""
      CommandStore.removeCustomCommand id
      @renderCommands()

  onImportFormSubmit: (e) =>
    e.preventDefault()
    gistID = @$importInput.val()
    return unless gistID

    @$importInput.val ""
    @loading()

    CommandStore
      .importCustomCommand(gistID)
      .done(@renderCommands)
      .fail(alert.bind(window))
      .always(@loaded)

  loading: => @$body.addClass "loading"
  loaded: => @$body.removeClass "loading"

  onHotkeyKeypress: (e) =>
    e.preventDefault()
    return if [13, 32].indexOf(e.which) isnt -1

    char = String.fromCharCode e.which
    @$hotkeyInput.val char
    @setHotkey char

  _setHotkey = (char) -> chrome.storage.sync.set "hotkey": char
  setHotkey: _.debounce _setHotkey, 250

  displayHotkey: ->
    chrome.storage.sync.get "hotkey", (storage) =>
      @$hotkeyInput.val storage?.hotkey or "`"

new Options