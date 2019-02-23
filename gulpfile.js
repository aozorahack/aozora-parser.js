/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const gulp        = require('gulp');
const peg         = require('gulp-peg');
const gutil       = require('gulp-util');
const shell       = require('gulp-shell');
const rename      = require('gulp-rename');
const prettify    = require('gulp-jsbeautifier');
const runSequence = require('run-sequence');
const through     = require('through2');
const parser      = require('./');

gulp.task('default', cb => runSequence('build', '$sample', cb));

// call task 'sample' via shell to avoid `require` cache
gulp.task('$sample', shell.task('gulp sample'));

gulp.task('build', () =>
  gulp.src('aozora-parser.pegjs')
  .pipe(peg().on('error', gutil.log))
  .pipe(gulp.dest('dist'))
);

gulp.task('sample', () =>
  gulp.src('test/sandbox/source.txt')
  .pipe(parse())
  .pipe(rename('output.json'))
  .pipe(prettify({indent_size: 2}))
  .pipe(gulp.dest('test/sandbox/'))
);

gulp.task('watch', function() {
  const o = {debounceDelay: 3000};
  gulp.watch(['test/sandbox/source.txt'], o, ['$sample']);
  return gulp.watch(['*.pegjs'], o, ['default']);
});

var parse = () =>
  through.obj(function(file, encoding, callback) {
    const result = parser.parse(file.contents.toString());
    file.contents = new Buffer(JSON.stringify(result));
    this.push(file);
    return callback();
  })
;
