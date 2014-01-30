coffee = require 'coffee-script'

module.exports = (grunt) ->

  grunt.initConfig
    clean:
      all: ['build']

    coffee:
      options:
        sourceMap: true
      all:
        src: '**/*.coffee'
        dest: 'lib'
        cwd: 'src'
        flatten: false
        expand: true
        ext: '.js'


    powerbuild:
      options:
        sourceMap: true
        node: false
        entryPoints: 'src/main.coffee'
        export: "Psy"
        output: 'build/psycloud.js'
        handlers:
          '.coffee': (src, canonicalName) ->
            console.log("compiling", canonicalName)
            {js, v3SourceMap} = coffee.compile src, sourceMap: true, bare: true
            return {code: js, map: v3SourceMap}

      all:
        files: [
          {src: "src/main.coffee", dest: 'build/psycloud.js'}
        ]
      min:
        options:
          minify: true
          compress: true
        files: [
          {src: "src/main.coffee", dest: 'build/psycloud.min.js'}
        ]

    watch:
      scripts:
        files: ['src/**/*.coffee']
        tasks: ['default']
        options:
          spawn: true



    concat:
      min:
        src: ['build/psycloud.min.js', 'jslibs/jquery-1.7.min.js', 'vex.combined.min.js']
        dest: 'build/psycloud_bundle.min.js'
      all:
        src: ['build/psycloud.js', 'jslibs/jquery-1.7.min.js', 'vex.combined.min.js']
        dest: 'build/psycloud_bundle.js'

    cssmin: 
      combine: 
        files: 
          'build/psycloud_bundle.css': ['css/*.css']




  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('powerbuild')
  grunt.registerTask('default', ['clean', 'powerbuild:all', 'concat:all', 'cssmin'])
  grunt.registerTask('power', ["powerbuild"])