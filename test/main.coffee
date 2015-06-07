should = require 'should'
parser = require '../'
gutil  = require 'gulp-util'
fs     = require 'fs'
path   = require 'path'

describe 'aozora-parser.js', () ->

  it 'parse basic', (done) ->
    title = 'basic'
    fixture = fs.readFileSync path.join(__dirname, 'fixtures', title + '.txt'), 'utf8'
    actual = JSON.stringify parser.parse fixture
    expected = fs.readFileSync path.join(__dirname, 'expect', title + '.json'), 'utf8'
    actual.should.equal expected
