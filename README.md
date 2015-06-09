# [WIP] aozora-parser.js

青空文庫テキストフォーマットのパーサー (試験実装中...)

HTMLやEPUBへのコンバータは含まれないので、別途用意する必要があります。

## 使い方

```javascript
var parser = require('./dist/aozora-parser')

var text = 'これは注記［＃「注記」に傍点］です。'
var result = parser.parse(text)
```

## 開発

開発の趣旨は以下の2つ。

- JavaScript版のパーサを作成すること
- 中間形式としてのAST(抽象構文木)を確定すること

### 準備

- インストール: `$ npm install`
- テスト: `$ npm test`


### 文法の編集

ファイル監視の開始をするには、次のコマンドを打ちます。

```
$ npm start
```

この状態で、

- `aozora-parser.pegjs`
- `test/sandbox/source.txt`

のどちらかを編集すると、自動的に`test/sandbox/output.json`が更新されるので、3画面を開いて進めると良さそうです。(パーサーも`dist/aozora-parser.js`に出力されています)

 ![スクリーンショット](images/screen1.png)

PEGの文法に誤り(ループなど)があったりすると、監視が止まっていることがあります。その場合は、一旦`Ctrl + C`でプロセスを止めて、再度`npm start`してください。


## Licenses

- aozora-parser.pegjs: BSD @kawabata氏の[LISP版](https://github.com/kawabata/aozora-proc)を元に、@takahashimさんの[gist](https://gist.github.com/takahashim/5b049a305128dcd12245)を経由して移植しました。
- その他: MIT
