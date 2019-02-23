/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const should = require('should');
const parser = require('../');
const gutil  = require('gulp-util');
const fs     = require('fs');
const path   = require('path');

describe('aozora-parser.js', function() {

  describe('要素ごとのテスト', () =>

    it('ルビ', function(done) {
      JSON.stringify(parser.parse('大学生の事を描《かい》た\n'))
      .should.equal('[[[null,[[[["大","学","生","の","事","を","描"],[],[["《","かい","》"],[]],[]],[["た"],[],null,[]]]],"\\n"],null]]');
      return done();
    })
  );

  return describe('青空文庫テキストファイル', () =>

    it('『それから』予告(ヘッダ/フッタなし)をパースできる', function(done) {
      const title = 'sorekara-yokoku-wo-meta';
      const fixture = fs.readFileSync(path.join(__dirname, 'fixtures', title + '.txt'), 'utf8');
      parser.parse(fixture);
      return done();
    })

    /*
    it 'それから』予告をパースできる', (done) ->
      title = 'sorekara-yokoku'
      fixture = fs.readFileSync path.join(__dirname, 'fixtures', title + '.txt'), 'utf8'
      parser.parse fixture
      done()
    */
  );
});
