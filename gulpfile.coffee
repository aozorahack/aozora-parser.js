gulp        = require 'gulp'
peg         = require 'gulp-peg'
gutil       = require 'gulp-util'
shell       = require 'gulp-shell'
rename      = require 'gulp-rename'
runSequence = require 'run-sequence'
through     = require 'through2'
parser      = require './'

gulp.task 'default', (cb) -> runSequence 'build', '$sample', cb

# call task 'sample' via shell to avoid `require` cache
gulp.task '$sample', shell.task 'gulp sample'

gulp.task 'build', ->
  gulp.src 'aozora-parser.pegjs'
  .pipe peg().on 'error', gutil.log
  .pipe gulp.dest 'dist'

gulp.task 'sample', ->
  gulp.src 'test/fixtures/*.txt'
  .pipe parse()
  .pipe rename extname: '.json'
  .pipe gulp.dest 'test/output/'

gulp.task 'watch', ->
  o = debounceDelay: 3000
  gulp.watch ['test/fixtures/*.txt'], o, ['$sample']
  gulp.watch ['*.pegjs'], o, ['default']

parse = ->
  through.obj (file, encoding, callback) ->
    result = parser.parse file.contents.toString()
    file.contents = new Buffer JSON.stringify result
    @push file
    callback()
