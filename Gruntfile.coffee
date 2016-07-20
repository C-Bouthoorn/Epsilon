module.exports = (grunt) ->

  # Get wwwroot from config
  CSON    = require 'cson'
  config  = CSON.parseFile 'config.cson'
  wwwroot = config.wwwroot


  grunt.initConfig {
    # Compile CoffeeScript
    coffee:
      compile_server:
        options:
          # bare: true
          sourceMap: true

          sourceMapDir: './sourceMaps'

        files: [
          expand: true
          cwd: ''
          src: [ './**/*.coffee', '!./Gruntfile.coffee', '!node_modules/**', '!.git/**',  ]
          dest: ''
          ext: '.js'
          extDot: 'last'
        ]

      compile_wwwroot:
        options:
          bare: true
          sourceMap: true

          sourceMapDir: wwwroot + '/sourceMaps'

        files: [
          expand: true
          cwd: ''
          src: [ wwwroot + '/**/*.coffee' ]
          dest: ''
          ext: '.js'
          extDot: 'last'
        ]


    # Compile SASS
    sass:
      compile_all:
        options:
          trace: true
          update: true

        files: [
          expand: true
          cwd: ''
          src: [ '**/*.scss', '**/*.sass', '!node_modules/**', '!.git/**' ]
          dest: ''
          ext: '.css'
          extDot: 'last'
        ]


    # Minify JavaScript
    uglify:
      minify_js_all:
        options:
          compress: true

          sourceMap: true

          sourceMapName: (file) ->
            filename = "#{ file.split('/').pop() }.map"

            # Seperate server files from www files
            if file.startsWith 'public_www'
              return "public_www/sourceMaps/#{filename}"
            else
              return "sourceMaps/#{filename}"

          preserveComments: false

        files: [
          expand: true
          cwd: ''
          src: [ '**/*.js', '!**/*.min.js', '!node_modules/**', '!.git/**' ]
          dest: ''
          ext: '.min.js'
          extDot: 'last'
        ]


    # Minify CSS
    cssmin:
      minify_css_all:
        options:
          sourceMap: true

        files: [
          expand: true
          cwd: ''
          src: [ '**/*.css', '!**/*.min.css', '!node_modules/**', '!.git/**' ]
          dest: ''
          ext: '.min.css'
          extDot: 'last'
        ]


    # Minify HTML
    htmlmin:
      minify_html_all:
        options:
          collapseWhitespace: true
          collapseBooleanAttributes: true

          removeComments: true
          removeRedundantAttributes: true
          removeScriptTypeAttributes: true
          removeStyleLinkTypeAttributes: true

          minifyCSS: true
          minifyJS: true
          minifyURLs: true

          sortAttributes: true
          sortClassName: true

        files: [
          expand: true
          cwd: ''
          src: [ '**/*.html', '!**/*.min.html', '!node_modules/**', '!.git/**' ]
          dest: ''
          ext: '.min.html'
          extDot: 'last'
        ]
  }

  # Load tasks
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-htmlmin'

  # Set default task
  grunt.registerTask 'default', ['coffee', 'sass', 'uglify', 'cssmin', 'htmlmin']
