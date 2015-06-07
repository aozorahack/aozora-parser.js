start = text

text = line*

line = line:chunk* newLine {
  return line
}

chunk
  = ruby
  / annotation
  / string

string
  = number
  / alpha
  / hira
  / kata
  / punctuation
  / bracket
  / space
  / halfNumber
  / halfAlpha
  / halfSpace

ruby = '《' ruby:hira '》' {
  return {
    type: "ruby",
    ruby: ruby
  }
}

annotation = '［＃' annotation:string '］' {
  return {
    type: "annotation",
    annotation: annotation
  }
}

hira        = $([ぁ-ゖ]+)
kata        = $([ァ-ヺ]+)
number      = $([０-９]+)
alpha       = $([ａ-ｚＡ-Ｚ]+)
punctuation = [。、・：；，．]
bracket     = [「」『』【】〔〕]
space       = $([　]+)

halfNumber  = $([0-9]+)
halfAlpha   = $([a-zA-Z]+)
halfSpace   = $([ \t]+)

newLine = '\n'
