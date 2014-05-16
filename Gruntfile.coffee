coffee = require 'coffee-script'

module.exports = (grunt) ->

  grunt.initConfig
    clean:
      all: ['build', 'lib']

    coffee:
      options:
        sourceMap: false
      all:
        src: '**/*.coffee'
        dest: 'lib'
        cwd: 'src'
        flatten: false
        expand: true
        ext: '.js'

    powerbuild:
      options:
        sourceMap: false
        node: false
        entryPoints: 'lib/main.js'
        export: "Psy"
        output: 'build/psycloud.js'
        #handlers:
        #  '.coffee': (src, canonicalName) ->
        #    console.log("compiling", canonicalName)
        #    {js, v3SourceMap} = coffee.compile src, sourceMap: true, bare: true
        #    return {code: js, map: v3SourceMap}

      all:
        files: [
          {src: "lib/main.js", dest: 'build/psycloud.js'}
        ]
      min:
        options:
          minify: true
          compress: true
        files: [
          {src: "lib/main.js", dest: 'build/psycloud.min.js'}
        ]

    watch:
      scripts:
        files: ['src/**/*.coffee']
        tasks: ['code']
        options:
          spawn: true


    concat_sourcemap:
      options:
        sourceRoot: ".."
      all:
        files:
          "build/psycloud_bundle.js": ['build/psycloud.js', 'jslibs/jqxcore.js', 'jslibs/jqxbuttons.js', 'jslibs/jqxslider.js', 'jslibs/jquery-1.7.js', 'vex.combined.min.js']


    concat:
      min:
        #src: ['build/psycloud.min.js', 'jslibs/jquery-1.7.min.js', 'jslibs/jqxcore.js', 'jslibs/jqxbuttons.js', 'jslibs/jqxslider.js', 'vex.combined.min.js']
        src: ['jslibs/buzz.js', 'jslibs/kinetic-v5.0.1.js', 'jslibs/jquery-1.7.min.js', 'jslibs/jqxcore.js', 'jslibs/jqxbuttons.js', 'jslibs/jqxslider.js', 'vex.combined.min.js', 'jslibs/semantic.js']
        dest: 'build/psycloud_libs.min.js'
      all:
        src: ['jslibs/buzz.js', 'jslibs/kinetic-v5.0.1.js', 'jslibs/jquery-1.7.js', 'jslibs/jqxcore.js', 'jslibs/jqxbuttons.js', 'jslibs/jqxslider.js', 'vex.combined.min.js', 'jslibs/semantic.js']
        dest: 'build/psycloud_libs.js'

    cssmin: 
      combine: 
        files: 
          'build/psycloud_bundle.css': ['css/*.css']

    copy:
      main:
        files: [
          expand: true
          flatten: true
          src: 'css/images/*'
          dest: 'build/images'
        ]


    shell:
      codo:
        command: 'codo src'




  grunt.loadNpmTasks('grunt-shell')
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-concat-sourcemap');
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('powerbuild')
  grunt.registerTask('code', ['clean', 'powerbuild:all', 'concat', 'copy'])
  #grunt.registerTask('default', ['clean', 'coffee', 'powerbuild:all', 'concat_sourcemap:all', 'cssmin', 'shell'])
  grunt.registerTask('default', ['clean', 'coffee', 'powerbuild:all', 'concat', 'cssmin', 'copy', 'shell'])
  grunt.registerTask('power', ["powerbuild"])
