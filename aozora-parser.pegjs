/*
 * 青空文庫注記の解析表現文法
 *
 * https://github.com/kawabata/aozora-proc/blob/master/grammar.txt
 * https://gist.github.com/takahashim/5b049a305128dcd12245
 */

/*
 * 青空文庫の「文字」の表記法
 */

Start
  = Block+

String
  = Char+

Char
  = $(!"\n" !"［＃" !"※［＃" !( "〔" LatinChar ) !"《" !"》" !"｜" .)
  / KanjiGaiji
  / NonKanjiGaiji
  / Kanbun

Kanji "漢字"
  = [\u3400-\u9FCB\uF900-\uFAD9]
  / [仝〆○々]
  / KanjiGaiji

Kana "かな"
  = [ぁ-んァ-ヶ゛-ゞ・-ヾ]
  / "／″＼"
  / "／＼"

KanjiGaiji "漢字外字" // 注記文字列をparseして第(3|4)水準漢字やUCSの情報を抽出する必要あり
  = "※［＃二の字点、1-2-22］"
  / "※［＃「" AnnString "］"
  / "※［＃二の字点、" AnnString "］"
  / "※［＃濁点付き二の字点、" AnnString "］"

NonKanjiGaiji "非漢字外字" // 注記文字列をparseして第(3|4)水準漢字やUCSの情報を抽出する必要あり
  = "※［＃" !"「" AnnString "］"

Kanbun "漢文"
  = KuntenOkuri? Kaeriten
  / KuntenOkuri

KuntenOkuri "訓点送り"
  = "［＃（" (Kanji / Kana)+ "）］"

Kaeriten "返り点"
  = "［＃" (KaeriJunjoen KaeriReten? / KaeriReten) "］"

KaeriJunjoen "返り順序点"
  = [一二三四上中下天地人甲乙丙丁]

KaeriReten "返りレ点"
  = "レ"

LatinChar "欧文字"
  = [a-zA-Zα-ρσ-ωΑ-ΡΣ-ΩА-яЁё]


/*
 * 青空文庫の文に対する「注記」の表記法
 */

GeneralString "一般文字列"
  = (
    s:$(String / LatinString) a1:QuoteAnn* r:GeneralRuby? a2:QuoteAnn* {
      var ret = {
        "type": "一般文字列",
        "value": s
      }
      if (r) ret.ruby = r
      if (a1.length || a2.length) ret.annotation = a1.concat(a2)
      return ret
    }
    / DefRuby QuoteAnn*
  )+

AnnString "注記文字列"
  = $(!"］" Char)+

QuoteString "引用文字列"
  = $(
    (QuoteChar+ / LatinString) QuoteAnn* GeneralRuby? QuoteAnn*
    / DefRuby QuoteAnn*
  )+

QuoteChar "引用文字"
  = $(!"」は" !"」の" !"」に" !"」］" Char)

QuoteAnn "引用注記"
  = ModifierAnn
  / OriginalAnn
  / TypistAnn

RubyAnn "ルビ注記"
  = RubyModifierAnn
  / RubyOriginalAnn
  / RubyTypistAnn

ModifierAnn "修飾注記"
  = "［＃「" q:QuoteString "」" m:Modifier "］" {
    return {
      "type": m[1],
      "target": q
    }
  }

RubyModifierAnn "ルビ修飾注記"
  = "［＃ルビの「" QuoteString "」" Modifier "］"

OriginalAnn "原文注記"
  = "［＃「" QuoteString "」" "の左"? "に「" QuoteString "」の注記］"

RubyOriginalAnn "ルビ原文注記"
  = "［＃ルビの「" QuoteString "」" "の左"? "に「" QuoteString "」の注記］"

TypistAnn "入力者注記"
  = "［＃「" QuoteString "」は" TeihonAnn "］"

RubyTypistAnn "ルビ入力者注記"
  = "［＃ルビの「" QuoteString "」は" TeihonAnn "］"

TeihonAnn "底本注記"
  = "底本では「" QuoteString "」"
  / "ママ"

Modifier "修飾指定"
  = "に" Em
  / "の" LeftEm
  / "の" LeftRuby
  / "は" Jitai
  / "は" CharSize

Em "強調"
  = "二重"? ("傍線" / "波線" / "破線" / "鎖線")
  / "傍点"
  / "白ゴマ傍点"
  / "丸傍点"
  / "白丸傍点"
  / "×傍点"
  / "黒三角傍点"
  / "白三角傍点"
  / "二重丸傍点"
  / "蛇の目傍点"
  / "白四角傍点"

LeftEm "左強調"
  = "左に" Em

LeftRuby "左ルビ"
  = "左に「" QuoteString "」のルビ"

Jitai "字体"
  = Heading
  / KeiKakomi
  / "太字"
  / "斜体"
  / "分数"
  / "上付き小文字"
  / "下付き小文字"
  / "篆書体"
  / "小書き"
  / "行右小書き"
  / "行左小書き"
  / "横組み"
  / "縦中横"
  / "合字"
  / "ローマ数字"

Heading "見出し"
  = ("窓" / "同行")? ("大" / "中" / "小") "見出し"

KeiKakomi "罫囲み"
  = "二重"? "罫囲み"

CharSize "文字サイズ"
  = Number "段階" (("大きな" / "小さな") "文字")

Number "数"
  = [0-9]+
  / [０-９]+
  / [一二三四五六七八九十]

GeneralRuby "一般ルビ"
  = r:GeneralRuby2 a:RubyAnn* {
    return !a.length ? r : {
      "type": "一般ルビ",
      "value": r,
      "annotation": a
    }
  }

DefRuby "指定ルビ"
  = DefRuby2 RubyAnn*

GeneralRuby2 "一般ルビ２"
  = "《" s:$String "》" {
    return s
  }

DefRuby2 "指定ルビ２"
  = "｜" (String / LatinString) QuoteAnn* "《" $String "》"

LatinString "欧文"
  = "〔" LatinChar (LatinChar / [!-~] / QuoteAnn)+ "〕"


/*
 * 青空文庫の「行」に対する注記法
 */

Line "行"
  = l:(GeneralAnn / GeneralString)+ {
    return {
      "type": "行",
      "value": l
    }
  }

GeneralAnn "一般注記"
  = KakomiAnn
  / Warichu
  / ChiyoseAnn
  / Figure
  / TeihonTypistAnn

KakomiAnn "囲み注記"
  = "［＃" ((Em / LeftEm / Jitai) / CharSize) "］"
    GeneralString
    "［＃" (Em / LeftEm / Jitai / CharSizeEnd) "終わり］"

Warichu "割り注"
  = "［＃割り注］"
    (Newline / GeneralString)+
    "［＃割り注終わり］"

Newline "改行"
  = "［＃改行］"

CharSizeEnd "文字サイズ終"
  = "大きな文字"
  / "小さな文字"

ChiyoseAnn "地上げ注記"
  = Chiyori
  / Chitsuki
  / Chiyose

Chiyori "地寄り"
  = "［＃下げて、地より" Number "字あきで］"

Chiyose "地上げ"
  = "［＃地から" Number "字上げ］"

Chitsuki "地付き"
  = "［＃地付き］"

Figure "図"
  = "［＃" FigureAnn ("(" / "（") FileName ".png" FigureSize? (")" / "）") "入る］"

FigureAnn "図注記"
  = (!"(" !"（" Char)+

FileName "ファイル名"
  = (!".png" Char)+

FigureSize "図大きさ"
  = "、横" Number "×縦" Number

TeihonTypistAnn "底本入力者注記"
  = "［＃底本では" AnnString "］"

/*
 * 青空文庫の段落ブロックに対する注記法
 */

Block "ブロック"
  = b:(
    PageDef
    / ParaIndent
    / ParaDef
    / Para
  ) "［＃本文終わり］"? {
    return {
      "type": "ブロック",
      "value": b
    }
  }

Block2 "ブロック２"
  = PageDef
  / ParaDef
  / Para

Block3 "ブロック３"
  = ParaIndent
  / ParaDef
  / Para

Para "段落"
  = i:Indent? l:Line? "\n" {
    return {
      "type": "段落",
      "indent": i || 0,
      "value": l
    }
  }

Indent "字下げ"
  = "［＃" n:Number "字下げ］" {
    return n
  }

PageDef "ページ指定"
  = Centering
  / ClearAnn

Centering "左右中央"
  = "［＃ページの左右中央］" "\n" Block3* "［＃改ページ］" "\n"

ClearAnn "改まり注記"
  = ("［＃改丁］" / "［＃改ページ］") "\n"

ParaDef "段落指定"
  = (
    ParaJizume
    / ParaChitsuki
    / ParaNegativeIndent
    / ClearColumn
    / ParaJitai
    / ParaLargeChar
    / ParaSmallChar
    / Column
  ) "\n"

ClearColumn "改段"
  = "［＃改段］"

ParaIndent "段落字下げ"
  = ParaIndent2 + IndentEnd "\n"

ParaIndent2 "段落字下げ2"
  = (
    NewlineTentsuki
    / LeftIndent
    / IndentBegin
    / IndentBegin2
  ) "\n" Block2*

NewlineTentsuki "改行天付き"
  = "［＃ここから改行天付き、折り返して" Number "字下げ］"

LeftIndent "天字下げ"
  = "［＃天から" Number "字下げ］"

IndentBegin "文字下げ"
  = "［＃ここから" Number "字下げ］"

IndentBegin2 "文字下げ２"
  = "［＃ここから" Number "字下げ、折り返して" Number "字下げ］"

IndentEnd "字下げ終"
  = "［＃ここで字下げ終わり］"

ParaJizume "段落字詰め"
  = "［＃ここから" Number "字詰め］\n" Block* "［＃ここで字詰め終わり］"

ParaChitsuki "段落地付き"
  = "［＃ここから地付き］\n" Block* "［＃ここで地付き終わり］"

ParaNegativeIndent "段落字上げ"
  = "［＃ここから地から" Number "字上げ］\n" Block* "［＃ここで字上げ終わり］"

ParaJitai "段落字体"
  = "［＃ここから" Jitai "］\n" Block* "［＃ここで" Jitai "終わり］"

ParaLargeChar "段落文字大"
  = "［＃ここから" Number "段階大きな文字］\n" Block* "［＃ここで大きな文字終わり］"

ParaSmallChar "段落文字小"
  = "［＃ここから" Number "段階小さな文字］\n" Block* "［＃ここで小さな文字終わり］"

Column "段組み"
  = "［＃ここから" Number "段組み" "、段間に罫"? "］\n" Block* "［＃ここで段組み終わり］"

/*
 * 制約条件
 *
 * 「囲み注記」 の開始・終了注記の字体修飾指定は一致しなければなりません。
 * 「修飾注記・原文注記等・原文注記・入力者注記・底本注記・左ルビ」における「引用文字列」は、
 * その直前の本文文字列と、注記表記の有無のいずれかで一致しなければなりません。
 */
