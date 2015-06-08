should = require 'should'
parser = require '../'
gutil  = require 'gulp-util'
fs     = require 'fs'
path   = require 'path'

describe 'aozora-parser.js', () ->

  it 'can parse sorekara-yokoku-wo-meta', (done) ->
    title = 'sorekara-yokoku-wo-meta'
    fixture = fs.readFileSync path.join(__dirname, 'fixtures', title + '.txt'), 'utf8'
    parser.parse fixture
    done()

  it 'can parse sorekara-yokoku', (done) ->
    title = 'sorekara-yokoku'
    fixture = fs.readFileSync path.join(__dirname, 'fixtures', title + '.txt'), 'utf8'
    parser.parse fixture
    done()
