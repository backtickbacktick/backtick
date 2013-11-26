require.config
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

require [
  "jquery"
], ->
  mocha.setup "bdd"
  window.expect = chai.expect
  window.should = chai.should()

  require [
    "lib/fuzzy-match"
  ], ->
    mocha.ignoreLeaks().run()
