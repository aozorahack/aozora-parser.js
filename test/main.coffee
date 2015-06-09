should = require 'should'
parser = require '../'
gutil  = require 'gulp-util'
fs     = require 'fs'
path   = require 'path'

describe 'aozora-parser.js', ->

  describe '要素ごとのテスト', ->

    it 'ルビ', (done) ->
      JSON.stringify parser.parse '大学生の事を描《かい》た\n'
      .should.equal '[[[null,[[[["大","学","生","の","事","を","描"],[],[["《","かい","》"],[]],[]],[["た"],[],null,[]]]],"\\n"],null]]'
      done()

  describe '青空文庫テキストファイル', ->

    it '『それから』予告(ヘッダ/フッタなし)をパースできる', (done) ->
      title = 'sorekara-yokoku-wo-meta'
      fixture = fs.readFileSync path.join(__dirname, 'fixtures', title + '.txt'), 'utf8'
      parser.parse fixture
      done()

    ###
    it 'それから』予告をパースできる', (done) ->
      title = 'sorekara-yokoku'
      fixture = fs.readFileSync path.join(__dirname, 'fixtures', title + '.txt'), 'utf8'
      parser.parse fixture
      done()
    ###
