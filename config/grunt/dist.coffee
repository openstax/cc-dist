module.exports = (grunt) ->
  grunt.config 'browserify',
    options:
      browserifyOptions:
        extensions: ['.js', '.coffee']
      bundleOptions:
        standalone: 'ExerciseComponent'
        debug: true # Source Maps
      transform: ['coffee-reactify']
    exercise:
      files:
        '.build/exercise.js': ['src/exercise.coffee']

  grunt.config 'clean',
    all: ['.build', 'dist']

  grunt.config 'concat',
    exercise:
      files:
        'dist/libs.js': [
          'bower_components/loader/loader.js'
          'htmlbars/vendor/handlebars.amd.js'
          'htmlbars/vendor/simple-html-tokenizer.amd.js'
          'htmlbars/htmlbars-compiler.amd.js'
          'htmlbars/htmlbars-runtime.amd.js'
          'htmlbars/morph.amd.js'
          'src/nodefine.js' # This removes the define added by loader
        ]
        'dist/exercise.js': ['.build/exercise.js']

  grunt.config 'mochaTest',
    test:
      options:
        reporter: 'spec'
        require: 'coffee-script'
      src: ['test/*.spec.coffee']
