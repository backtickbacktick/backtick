define [
  "underscore"
  "jquery"
  "backbone"
  "handlebars"
  "lib/extension"
  "text!../templates/root.hbs"
  "text!../templates/container.hbs"
  "text!../templates/nag-message.txt"
], (
  _
  $
  Backbone
  Handlebars
  Extension
  rootTemplate
  containerTemplate
  nagMessage
) ->
  class App
    @USES_BETWEEN_NAG_DIALOG: 15
    @LICENSE_URL: "https://chrome.google.com/webstore/detail/" +
                  "backtick-license/fdocciflgajbbcgmnfifnmoamjgiefip"

    open: false
    loading: false
    commands: []
    env: if chrome.runtime then "extension" else "development"

    constructor: ->
      _.extend this, Backbone.Events

      @on "open", @setOpen.bind(this)
      @on "close", @setClosed.bind(this)

    start: ->
      @appendContainer()
      @trigger "loadConsole.action"

      @on "load.commands", @setOpen.bind(this)
      @on "load.commands sync.commands", (commands) => @commands = commands

      @on "execute.commands", @setLoading.bind(this)
      @on "executed.commands executionError.commands", @setLoaded.bind(this)

      Extension.trigger "ready.app"

      @on "toggle.app", ->
        if @open
          @trigger "close"
        else
          @trigger "open"

      @on "unlicensedUse.app", @countUnlicensedUses.bind(this)

    countUnlicensedUses: ->
      chrome.storage.sync.get 'unlicensedUses', (storage) =>
        uses = storage.unlicensedUses or 0
        uses++

        if uses % App.USES_BETWEEN_NAG_DIALOG is 0
          @showNagDialog()

        chrome.storage.sync.set unlicensedUses: uses

    showNagDialog: ->
      openLicensePage = confirm nagMessage
      window.open(App.LICENSE_URL, "_blank") if openLicensePage

    setOpen: ->
      @open = true
      window._BACKTICK_OPEN = true

    setClosed: ->
      @open = false
      window._BACKTICK_OPEN = false

    setLoading: ->
      @loading = true
      @$console.addClass "loading"

    setLoaded: ->
      @loading = false
      @$console.removeClass "loading"

    appendContainer: ->
      @$el = $(Handlebars.compile(rootTemplate)()).appendTo "body"

      if @env is "extension"
        createShadowRoot = \
          @$el[0].createShadowRoot or @$el[0].webkitCreateShadowRoot

        shadow = createShadowRoot.apply @$el[0]

        cssPath = "styles/style.css"
        cssPath = chrome.extension.getURL(cssPath) if chrome.extension
        shadow.innerHTML = Handlebars.compile(containerTemplate)(cssPath: cssPath)

        @$console = $ shadow.querySelector("#console")
        @$results = $ shadow.querySelector("#results")
        @$settings = $ shadow.querySelector("#settings")
      else
        @$el.append Handlebars.compile(containerTemplate)(cssPath: null)

        @$console = @$el.find "#console"
        @$results = @$el.find "#results"
        @$settings = @$el.find "#settings"

  new App
