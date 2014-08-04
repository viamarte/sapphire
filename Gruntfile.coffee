#Gruntfile for Sapphire
#Author: Matheus R. Kautzmann
#Company: Via Marte 2013
#Date: 01/07/2013

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    simplemocha:
      options:
        reporter: "spec"
        ignoreLeaks: false
        compilers: "coffee"
      all:
        src: "test/*"
    #Codo documentation, workaround until it gets Grunt compatible
    shell:
      document:
        command: "codo --private true --title Sapphire Docs -o ./docs src"
      coverage:
        command: "mocha --compilers coffee:coffee-script/register -r blanket
         -R html-cov > coverage.html"
    coffeelint:
      app: ["*.coffee", "src/*.coffee"]
    coffee:
      compile:
        files:
          "lib/DBPM.js" : "src/DBPM.coffee"
          "lib/Sanitization.js" : "src/Sanitization.coffee"
          "lib/Validation.js" : "src/Validation.coffee"
          "lib/index.js" : "src/index.coffee"
          "lib/Util.js" : "src/Util.coffee"
    clean: ["lib", "docs", "coverage.html"]
    watch:
      coffee:
        files: ["src/*.coffee"]
        tasks: "coffee"


  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.loadNpmTasks "grunt-shell"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"

  grunt.registerTask "default", ["coffeelint", "coffee", "document",
   "simplemocha"]
  grunt.registerTask "document", ["shell:document"]
  grunt.registerTask "coverage", ["shell:coverage"]
  grunt.registerTask "test", ["simplemocha"]
  grunt.registerTask "lint", ["coffeelint"]
  grunt.registerTask "compile", ["coffee"]
  grunt.registerTask "publish", ["default"]
  grunt.registerTask "build", ["default"]
