require.config
  deps: ["main"]

  shim: {
    handlebars: exports: "Handlebars"
  }

  paths:
    # RequireJS plugins
    text: "../vendor/text/text"

    # Third party libraries
    jquery: "../vendor/jquery/jquery"
    handlebars: "../vendor/handlebars/handlebars"
    backbone: "../vendor/backbone-amd/backbone"
    underscore: "../vendor/underscore-amd/underscore"

    app: "app"

define ->
  API_URL: "#{location.hostname}:4000"