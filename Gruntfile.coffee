module.exports = (grunt) ->

  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'


    # Compile CoffeeScript
    coffee:
      compile:
        options:
          bare: true
          sourceMap: true

          # TODO: Don't place root maps in public folder
          sourceMapDir: 'public_www/sourceMaps'

        files: [
          expand: true
          cwd: ''
          src: [ '!node_modules/**', '**/*.coffee', '!Gruntfile.coffee', '!node_modules/**' ]
          dest: ''
          ext: '.js'
          extDot: 'last'
        ]


    # Compile SASS
    sass:
      compile:
        options:
          trace: true
          update: true

        files: [
          expand: true
          cwd: ''
          src: [ '!node_modules/**', '**/*.scss', '**/*.sass', '!node_modules/**']
          dest: ''
          ext: '.css'
          extDot: 'last'
        ]


    # Minify JavaScript
    uglify:
      uglifyjs:
        options:
          compress: true

          sourceMap: true
          sourceMapName: (file) ->
            filename = "#{ file.split('/').pop() }.map"

            if file.startsWith 'public_www'
              return "public_www/sourceMaps/#{filename}"
            else
              return "sourceMaps/#{filename}"

          preserveComments: false

        files: [
          expand: true
          cwd: ''
          src: [ '!node_modules/**', '**/*.js', '!**/*.min.js', '!node_modules/**' ]
          dest: ''
          ext: '.min.js'
          extDot: 'last'
        ]


    # Minify CSS
    cssmin:
      uglifycss:
        options:
          sourceMap: true

        files: [
          expand: true
          cwd: ''
          src: [ '!node_modules/**', '**/*.css', '!**/*.min.css', '!node_modules/**' ]
          dest: ''
          ext: '.min.css'
          extDot: 'last'
        ]


    # Minify HTML
    htmlmin:
      uglifyhtml:
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
          src: [ '!node_modules/**', '**/*.html', '!**/*.min.html', '!node_modules/**' ]
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
