module.exports = function(grunt) {

    require('load-grunt-tasks')(grunt);

    const config = {
        npmJs: [
            'node_modules/jquery/dist/jquery.min.js',
            'node_modules/jquery/dist/jquery.min.map'
        ]
    };

    const fileName = (path) => path.slice(path.lastIndexOf('/') + 1);

    grunt.initConfig({

        pkg: grunt.file.readJSON('package.json'),

        clean: {
            start: {
                src: ['_dist', '.tmp']
            },
            end: {
                src: ['.tmp']
            }
        },

        sass: {
            dist: {
                files: {
                    'styles/style.css': 'styles/style.scss'
                }
            }
        },

        copy: {
            main: {
                files: [
                    {
                        expand: true,
                        src: ['fonts/**', 'images/**', 'background.html', 'options.html', 'manifest.json'],
                        dest: '_dist/'
                    },
                    {
                        expand: true,
                        cwd: '.tmp/scripts/',
                        src: ['*.js', '*.map'],
                        dest: '_dist/scripts'
                    },
                    {
                        expand: true,
                        cwd: 'styles',
                        src: ['*.css'],
                        dest: '_dist/styles'
                    }
                ]
                    .concat(config.npmJs.map(src => ({ src, dest: '_dist/scripts/' + fileName(src) })))
            }
        },

        concat: {
            options: {
                separator: '\r\n\r\n',
                stripBanners: true,
                banner: '(function(){\r\n\r\n',
                footer: '\r\n\r\n\r\n\r\n})();'
            },
            main: {
                files: [
                    {
                        src: [
                            'scripts/config.js',
                            'scripts/lib/add-gist.js',
                            'scripts/lib/commands.js',
                            'scripts/lib/console.js',
                            'scripts/lib/store.js',
                            'scripts/main.js'
                        ],
                        dest: '.tmp/scripts/main.js'
                    },
                    {
                        src: [
                            'scripts/config.js',
                            'scripts/lib/analytics.js',
                            'scripts/lib/add-gist.js',
                            'scripts/lib/store.js',
                            'scripts/options.js'
                        ],
                        dest: '.tmp/scripts/options.js'
                    }
                ]
            }
        },

        babel: {
            options: {
                sourceMap: true,
                presets: ['es2015'],
                plugins: [
                    ['transform-class-properties', { 'spec': true }]
                ]
            },
            dist: {
                files: [
                    {
                        expand: true,
                        cwd: 'scripts/',
                        src: ['background.js', 'content-script.js'],
                        dest: '.tmp/scripts/'
                    },
                    {
                        expand: true,
                        cwd: '.tmp/scripts/',
                        src: ['main.js'],
                        dest: '.tmp/scripts/'
                    },
                    {
                        expand: true,
                        cwd: '.tmp/scripts/',
                        src: ['options.js'],
                        dest: '.tmp/scripts/'
                    }
                ]
            }
        },

        uglify: {
            stick: {
                options: {
                    sourceMap: true,
                    sourceMapName: '.tmp/scripts/main.min.map'
                },
                files: {
                    '.tmp/scripts/main.min.js': ['.tmp/scripts/main.js']
                }
            }
        },

        watch: {
            scripts: {
                files: ['scripts/*.js', 'scripts/**/*.js'],
                tasks: [
                    'concat',
                    'babel',
                    //'uglify',
                    'copy',
                    'clean:end'
                ],
                options: {
                    spawn: false
                }
            },
            styles: {
                files: ['styles/*.scss', 'styles/**/*.scss'],
                tasks: ['sass', 'copy'],
                options: {
                    spawn: false
                }
            },
            others: {
                files: ['fonts/**', 'images/**', 'background.html', 'options.html', 'manifest.json'],
                tasks: ['copy'],
                options: {
                    spawn: false
                }
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-sass');

    grunt.registerTask('default', [
        'clean:start',
        'sass',
        'concat',
        'babel',
        //'uglify',
        'copy',
        'clean:end'
    ]);
};