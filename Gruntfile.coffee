module.exports = (grunt)->

    grunt.loadTasks tasks for tasks in grunt.file.expand './node_modules/grunt-*/tasks'

    grunt.config.init
        coffee:
            dev:
                options:
                    sourceMap: true
                files: [expand:true, cwd:'./src', src:'**/*.coffee', dest:'./dist', ext:'.js']

        clean:
            dist: ['./dist']

        mochaTest:
            options:
                bail:     true
                color:    true
                reporter: 'dot'
                require: [
                    'coffee-script/register'
                    './test/test_helper.coffee'
                ]
                verbose: true
            src: ['./test/**/*.test.coffee']

        watch:
            coffee:
                files: ['./src/**/*.coffee']
                tasks: ['coffee']
            sql:
                files: ['./src/**/*.sql']
                tasks: ['rebuild-db']
            test:
                files: ['./src/**/*.coffee', './src/**/*.js', './test/**/*.coffee']
                tasks: ['test']

    grunt.registerTask 'default', 'build'

    grunt.registerTask 'build', ['coffee']
    
    grunt.registerTask 'dist', ['build', 'test']

    grunt.registerTask 'rebuild-db', "clears out the current db schema and rebuilds", ->
        done = this.async()
        options = cmd:'/usr/local/bin/mysql', args:['-u', 'root', '-D', 'music', '-e', '\\. src/schema.sql']
        grunt.util.spawn options, -> done()

    grunt.registerTask 'test', ['mochaTest']

    grunt.registerTask 'watch-dev', ['clean', 'build', 'watch']

    grunt.registerTask 'watch-test', ['clean', 'build', 'watch:test']
