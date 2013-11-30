try
  aws = require "./auth/aws"
catch e
  aws = {}

config =
  watch:
    coffee:
      files: ["{app,extension}/**/*.coffee"]
      tasks: ["coffee:server"]

    coffeeTest:
      files: ["test/**/*.coffee"]
      tasks: ["coffee:test"]

    compass:
      files: ["app/styles/{,*/}*.{scss,sass}"],
      tasks: ["compass:server"]

    livereload:
      options:
        livereload: "<%= connect.options.livereload %>"

      files: [
        "app/index.html"
        ".tmp/styles/{,*/}*.css"
        ".tmp/{scripts,extension,spec}/{,*/}*.js"
        "app/images/{,*/}*.{gif,jpeg,jpg,png,svg,webp}"
      ]

  connect:
    options:
      port: 9000
      livereload: 35729
      hostname: "0.0.0.0"

    livereload:
      options:
        open: true
        base: [
          ".tmp"
          "app"
        ]

    test:
      options:
        open: true
        base: [
          ".tmp"
          "test"
          "app"
        ]

  clean:
    dist:
      files: [
        dot: true
        src: [
          ".tmp"
          "dist/*"
          "!dist/.git"
        ]
      ]

    server: '.tmp'

  mocha:
    all:
      options:
        run: true
        urls: ["http://<%= connect.test.options.hostname %>:" +
               "<%= connect.test.options.port %>/index.html"]

  compass:
    options:
      sassDir: "app/styles"
      specify: ["app/styles/style.scss", "app/styles/container.scss"]
      imagesDir: "app/assets/images"
      importPath: "app/styles"
      relativeAssets: false
      assetCacheBuster: false
      noLineComments: true
      outputStyle: "compact"

    server:
      options:
        cssDir: ".tmp/styles"

    dist:
      options:
        cssDir: "dist/styles"

  coffee:
    server:
      files: [{
        expand: true
        cwd: "app/scripts"
        src: "**/*.coffee"
        dest: ".tmp/scripts"
        ext: ".js"
      }, {
        expand: true
        cwd: "extension"
        src: "**/*.coffee"
        dest: ".tmp/extension"
        ext: ".js"
      }]

    test:
      files: [
        expand: true
        cwd: "test/spec"
        src: "**/*.coffee"
        dest: ".tmp/spec"
        ext: ".js"
      ]

    ext:
      files: [
        expand: true
        cwd: "extension"
        src: "**/*.coffee"
        dest: "dist/extension"
        ext: ".js"
      ]

  requirejs:
    dist:
      options:
        mainConfigFile: ".tmp/scripts/config.js"
        name: "config"
        out: "dist/scripts/app.js"
        baseUrl: ".tmp/scripts"
        preserveLicenseComments: false
        wrap: false

  copy:
    dist:
      files: [
        expand: true
        dot: true
        cwd: "app"
        dest: "dist"
        src: [
          "assets/{,*/}*"
          "!assets/images/*"
          "vendor/jquery/jquery.js"
          "vendor/requirejs/require.js"
          "vendor/underscore-amd/underscore.js"
        ]
      ]

    ext:
      files: [{
        expand: true
        dot: true
        cwd: "extension"
        dest: "dist/extension"
        src: [
          "background.html"
          "options.html"
          "icon128.png"
        ]
      }, {
        expand: true
        dot: true
        cwd: "extension"
        dest: "dist"
        src: [
          "manifest.json"
        ]
      }]

    vendor:
      files: [
        expand: true
        dot: true
        cwd: "app"
        dest: ".tmp"
        src: ["vendor/{,*/}*.js"]
      ]

    templates:
      files: [
        expand: true
        dot: true
        cwd: "app"
        dest: ".tmp"
        src: ["templates/{,*/}*"]
      ]

    assets:
      files: [
        expand: true
        dot: true
        cwd: "app"
        dest: ".tmp"
        src: ["assets/{,*/}*"]
      ]

  concurrent:
    server: [
      "compass:server"
      "coffee:server"
    ]

    test: [
      "coffee:server"
      "coffee:test"
    ]

    dist: [
      "compass:dist"
      "coffee"
    ]

  s3:
    options:
      key: aws.key
      secret: aws.secret
      bucket: aws.bucket
      access: "public-read"
      gzip: true

    dist:
      upload: [
        src: "commands.json",
        dest: "commands.json"
      ,
        src: "commands.json"
        dest: "commands#{Date.now()}.json"
      ]

  compress:
    main:
      options:
        archive: "bin/backtick.zip"

      files: [
        src: ["dist/**"]
      ]

module.exports = (grunt) ->
  require("time-grunt") grunt
  require("load-grunt-tasks") grunt
  require("./tasks/build-commands") grunt

  grunt.initConfig config

  grunt.registerTask "serve", [
    "clean:server"
    "concurrent:server"
    "connect:livereload"
    "watch"
  ]

  grunt.registerTask "test", [
    "clean:server"
    "concurrent:test"
    "connect:test"
    "watch"
  ]

  grunt.registerTask "build", [
    "clean:dist"
    "concurrent:dist"
    "copy"
    "requirejs"
  ]

  grunt.registerTask "package", [
    "build"
    "compress"
  ]

  grunt.registerTask "upload-commands", [
    "build-commands",
    "s3"
  ]

  grunt.registerTask "default", [
    "build"
  ]
