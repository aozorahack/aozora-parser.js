/*
 * 青空文庫注記の解析表現文法
 *
 * 青空文庫の注記記法の解析表現文法による表現（案）です。
 * 詳細は `aozora-proc.el' を参照してください。
 *
 * Original: https://github.com/kawabata/aozora-proc/blob/master/grammar.txt
 * Original Author: Taichi Kawabata <kawabata.taichi@gmail.com>
 * License: BSD
 */

// 青空文庫の「文字」の表記法

//  : 文字列 ← 文字 +
String = Char+
//  : 文字 ← ( !( "\n" ) !( "［＃" ) !( "※［＃" ) !( ( "〔" 欧文字 ) ) !( "《" ) !( "》" ) !( "｜" ) .) / 漢字外字 / 非漢字外字 / 漢文
Char = ( !( "\n" ) !( "［＃" ) !( "※［＃" ) !( ( "〔" LatinChar ) ) !( "《" ) !( "》" ) !( "｜" ) .) / KanjiGaiji / NonKanjiGaiji / Kanbun
//  : 漢字 ← ( [ 㐀-鿋 豈-龎 𠀀-𯿽 ] [ 󠄀-󠇯 ] ? ) / [ "仝〆○々" ] / 漢字外字
//Kanji = ( [ 㐀-鿋 豈-龎 𠀀-𯿽 ] [ 󠄀-󠇯 ] ? ) / [ "仝〆○々" ] / KanjiGaiji
Kanji =  [ "仝〆○々" ] / KanjiGaiji
//  : かな ← [ ぁ-ん ァ-ヶ ゛-ゞ ・-ヾ ] / "／″＼" / "／＼"
Kana = [ ぁ-ん ァ-ヶ ゛-ゞ ・-ヾ ] / "／″＼" / "／＼"
//  : 漢字外字 ← ( "※［＃二の字点、1-2-22］" / ( "※［＃「" 注記文字列 "］" ) / ( "※［＃二の字点、" 注記文字列 "］" ) / ( "※［＃濁点付き二の字点、" 注記文字列 "］" ) )
// 注意: 注記文字列をparseして第(3|4)水準漢字やUCSの情報を抽出する必要あり
KanjiGaiji = ( "※［＃二の字点、1-2-22］" / ( "※［＃「" AnnString "］" ) / ( "※［＃二の字点、" AnnString "］" ) / ( "※［＃濁点付き二の字点、" AnnString "］" ) )
//  : 非漢字外字 ← ( "※［＃" !( "「" ) 注記文字列 "］" )
// 注意: 注記文字列をparseして第(3|4)水準漢字やUCSの情報を抽出する必要あり
NonKanjiGaiji = ( "※［＃" !( "「" ) AnnString "］" )
//  : 漢文 ← ( ( 訓点送り ? 返り点 ) / 訓点送り )
Kanbun = ( ( KuntenOkuri ? Kaeriten ) / KuntenOkuri )
//  : 訓点送り ← "［＃（" ( 漢字 / かな ) + "）］"
KuntenOkuri = "［＃（" ( Kanji / Kana ) + "）］"
//  : 返り点 ← "［＃" ( ( 返り順序点 返りレ点 ? ) / 返りレ点 ) "］"
Kaeriten = "［＃" ( ( KaeriJunjoen KaeriReten ? ) / KaeriReten ) "］"
//  : 返り順序点 ← [ "一二三四上中下天地人甲乙丙丁" ]
KaeriJunjoen = [ "一二三四上中下天地人甲乙丙丁" ]
//  : 返りレ点 ← "レ"
KaeriReten = "レ"
//  : 欧文字 ← [ a-z A-Z α-ρ σ-ω Α-Ρ Σ-Ω А-я " Ёё" ]
LatinChar = [ a-z A-Z α-ρ σ-ω Α-Ρ Σ-Ω А-я " Ёё" ]

// * 青空文庫の文に対する「注記」の表記法

//  : 一般文字列 ← ( ( ( 文字列 / 欧文 ) 引用注記 * 一般ルビ ? 引用注記 * ) / ( 指定ルビ 引用注記 * ) ) +
GeneralString = ( ( ( String / LatinString ) QuoteAnn * GeneralRuby ? QuoteAnn * ) / ( DefRuby QuoteAnn * ) ) +
//  : 注記文字列 ← ( !( "］" ) 文字 ) +
AnnString = ( !( "］" ) Char ) +
//  : 引用文字列 ← ( ( ( 引用文字 + / 欧文 ) 引用注記 * 一般ルビ ? 引用注記 * ) / ( 指定ルビ 引用注記 * ) ) +
QuoteString = ( ( ( QuoteChar + / LatinString ) QuoteAnn * GeneralRuby ? QuoteAnn * ) / ( DefRuby QuoteAnn * ) ) +
//  : 引用文字 ← ( !( "」は" ) !( "」の" ) !( "」に" ) !( "」］" ) 文字 ) +
QuoteChar = ( !( "」は" ) !( "」の" ) !( "」に" ) !( "」］" ) String ) +
//  : 引用注記 ← 修飾注記 / 原文注記 / 入力者注記
QuoteAnn = ModifierAnn / OriginalAnn / TypistAnn
//  : ルビ注記 ← ルビ修飾注記 / ルビ原文注記 / ルビ入力者注記
RubyAnn = RubyModifierAnn / RubyOriginalAnn / RubyTypistAnn
//  : 修飾注記 ← ( "［＃「" 引用文字列 "」" 修飾指定 "］" )
ModifierAnn = ( "［＃「" QuoteString "」" Modifier "］" )
//  : ルビ修飾注記 ← ( "［＃ルビの「" 引用文字列 "」" 修飾指定 "］" )
RubyModifierAnn = ( "［＃ルビの「" QuoteString "」" Modifier "］" )
//  : 原文注記 ← ( "［＃「" 引用文字列 "」" "の左" ? "に「" 引用文字列 "」の注記］" )
OriginalAnn = ( "［＃「" QuoteString "」" "の左" ? "に「" QuoteString "」の注記］" )
//  : ルビ原文注記 ← ( "［＃ルビの「" 引用文字列 "」" "の左" ? "に「" 引用文字列 "」の注記］" )
RubyOriginalAnn = ( "［＃ルビの「" QuoteString "」" "の左" ? "に「" QuoteString "」の注記］" )
//  : 入力者注記 ← ( "［＃「" 引用文字列 "」は" 底本注記 "］" )
TypistAnn = ( "［＃「" QuoteString "」は" TeihonAnn "］" )
//  : ルビ入力者注記 ← ( "［＃ルビの「" 引用文字列 "」は" 底本注記 "］" )
RubyTypistAnn = ( "［＃ルビの「" QuoteString "」は" TeihonAnn "］" )
//  : 底本注記 ← ( "底本では「" 引用文字列 "」" ) / "ママ"
TeihonAnn = ( "底本では「" QuoteString "」" ) / "ママ"
//  : 修飾指定 ← ( "に" 強調 ) / ( "の" 左強調 ) / ( "の" 左ルビ ) / ( "は" 字体 ) / ( "は" 文字サイズ )
Modifier = ( "に" Em ) / ( "の" LeftEm ) / ( "の" LeftRuby ) / ( "は" Jitai ) / ( "は" CharSize )
//  : 強調 ← ( "二重" ? ( "傍線" / "波線" / "破線" / "鎖線" ) ) / "傍点" / "白ゴマ傍点" / "丸傍点" / "白丸傍点" / "×傍点" / "黒三角傍点" / "白三角傍点" / "二重丸傍点" / "蛇の目傍点" / "白四角傍点"
Em = ( "二重" ? ( "傍線" / "波線" / "破線" / "鎖線" ) ) / "傍点" / "白ゴマ傍点" / "丸傍点" / "白丸傍点" / "×傍点" / "黒三角傍点" / "白三角傍点" / "二重丸傍点" / "蛇の目傍点" / "白四角傍点"
//  : 左強調 ← "左に" 強調
LeftEm = "左に" Em
//  : 左ルビ ← "左に「" 引用文字列 "」のルビ"
LeftRuby = "左に「" QuoteString "」のルビ"
//  : 字体 ← 見出し / 罫囲み / "太字" / "斜体" / "分数" / "上付き小文字" / "下付き小文字" / "篆書体" / "小書き" / "行右小書き" / "行左小書き" / "横組み" / "縦中横" / "合字" / "ローマ数字"
Jitai = Heading / KeiKakomi / "太字" / "斜体" / "分数" / "上付き小文字" / "下付き小文字" / "篆書体" / "小書き" / "行右小書き" / "行左小書き" / "横組み" / "縦中横" / "合字" / "ローマ数字"
//  : 見出し ← ( "窓" / "同行" ) ? ( "大" / "中" / "小" ) "見出し"
Heading = ( "窓" / "同行" ) ? ( "大" / "中" / "小" ) "見出し"
//  : 罫囲み ← "二重" ? "罫囲み"
KeiKakomi = "二重" ? "罫囲み"
//  : 文字サイズ ← 数 "段階" ( ( "大きな" / "小さな" ) "文字" )
CharSize = Number "段階" ( ( "大きな" / "小さな" ) "文字" )
//  : 数 ← ( [ 0-9 ] + / [ ０-９ ] + / [ "一二三四五六七八九十" ] )
Number = ( [ 0-9 ] + / [ ０-９ ] + / [ "一二三四五六七八九十" ] )
//  : 一般ルビ ← 一般ルビ２ ルビ注記 *
GeneralRuby = GeneralRuby2 RubyAnn *
//  : 指定ルビ ← 指定ルビ２ ルビ注記 *
DefRuby = DefRuby2 RubyAnn *
//  : 一般ルビ２ ← ( "《" 文字列 "》" )
GeneralRuby2 = ( "《" String "》" )
//  : 指定ルビ２ ← ( "｜" ( 文字列 / 欧文 ) 引用注記 * "《" 文字列 "》" )
DefRuby2 = ( "｜" ( String / LatinString ) QuoteAnn * "《" String "》" )
//  : 欧文 ← ( "〔" 欧文字 ( 欧文字 / [ !-~ ] / 引用注記 ) + "〕" )
LatinString = ( "〔" LatinChar ( LatinChar / [ !-~ ] / QuoteAnn ) + "〕" )

//* 青空文庫の「行」に対する注記法

//  : 行 ← ( 一般注記 / 一般文字列 ) +
Line = ( GeneralAnn / GeneralString ) +
//  : 一般注記 ← 囲み注記 / 割り注 / 地上げ注記 / 図 / 底本入力者注記
GeneralAnn = KakomiAnn / Warichu / ChiyoseAnn / Figure / TeihonTypistAnn  // 地上げ→地寄せ
//  : 囲み注記 ← ( "［＃" ( ( 強調 / 左強調 / 字体 ) / 文字サイズ ) "］" 一般文字列 "［＃" ( 強調 / 左強調 / 字体 / 文字サイズ終 ) "終わり］" )
KakomiAnn = ( "［＃" ( ( Em / LeftEm / Jitai ) / CharSize ) "］" GeneralString "［＃" ( Em / LeftEm / Jitai / CharSizeEnd ) "終わり］" )
//  : 割り注 ← ( "［＃割り注］" ( 改行 / 一般文字列 ) + "［＃割り注終わり］" )
Warichu = ( "［＃割り注］" ( Newline / GeneralString ) + "［＃割り注終わり］" )
//  : 改行 ← "［＃改行］"
Newline = "［＃改行］"
//  : 文字サイズ終 ← "大きな文字" / "小さな文字"
CharSizeEnd = "大きな文字" / "小さな文字"
//  : 地上げ注記 ← ( 地寄り / 地付き / 地上げ )
ChiyoseAnn = ( Chiyori / Chitsuki / Chiyose )
//  : 地寄り ← "［＃下げて、地より" 数 "字あきで］"
Chiyori = "［＃下げて、地より" Number "字あきで］"
//  : 地上げ ← "［＃地から" 数 "字上げ］"
Chiyose = "［＃地から" Number "字上げ］"
//  : 地付き ← "［＃地付き］"
Chitsuki = "［＃地付き］"
//  : 図 ← ( "［＃" 図注記 ( "(" / "（" ) ファイル名 ".png" 図大きさ ? ( ")" / "）" ) "入る］" )
Figure = ( "［＃" FigureAnn ( "(" / "（" ) FileName ".png" FigureSize ? ( ")" / "）" ) "入る］" )
//  : 図注記 ← ( !( "(" ) !( "（" ) 文字 ) +
FigureAnn = ( !( "(" ) !( "（" ) Char ) +
//  : ファイル名 ← ( !( ".png" ) 文字 ) +
FileName = ( !( ".png" ) Char ) +
//  : 図大きさ ← "、横" 数 "×縦" 数
FigureSize = "、横" Number "×縦" Number
//  : 底本入力者注記 ← ( "［＃底本では" 注記文字列 "］" )
TeihonTypistAnn = ( "［＃底本では" AnnString "］" )

// * 青空文庫の段落ブロックに対する注記法

//  : ブロック ← ( ページ指定 / 段落字下げ / 段落指定 / 段落 ) "［＃本文終わり］" ?
Block = ( PageDef / ParaIndent / ParaDef / Para ) "［＃本文終わり］" ?
//  : ブロック２ ← ページ指定 / 段落指定 / 段落
Block2 = PageDef / ParaDef / Para
//  : ブロック３ ← 段落字下げ / 段落指定 / 段落
Block3 = ParaIndent / ParaDef / Para
//  : 段落 ← 字下げ ? 行 ?  "\n"
Para = Indent ? Line ? "\n"
//  : 字下げ ← ( "［＃" 数 "字下げ］" )
Indent = ( "［＃" Number "字下げ］" )
//  : ページ指定 ← 左右中央 / 改まり注記
PageDef = Centering / ClearAnn
//  : 左右中央 ← "［＃ページの左右中央］" "\n" ブロック３ * "［＃改ページ］" "\n"
Centering = "［＃ページの左右中央］" "\n" Block3 * "［＃改ページ］" "\n"
//  : 改まり注記 ← ( "［＃改丁］" / "［＃改ページ］" ) "\n"
ClearAnn = ( "［＃改丁］" / "［＃改ページ］" ) "\n"
//  : 段落指定 ← ( 段落字詰め / 段落地付き / 段落字上げ / 改段 / 段落字体 / 段落文字大 / 段落文字小 / 段組み ) "\n"
ParaDef = ( ParaJizume / ParaChitsuki / ParaNegativeIndent / ClearColumn / ParaJitai / ParaLargeChar / ParaSmallChar / Column ) "\n"
//  : 改段 ← "［＃改段］"
ClearColumn = "［＃改段］"
//  : 段落字下げ ← 段落字下げ2 + 字下げ終 "\n"
ParaIndent = ParaIndent2 + IndentEnd "\n"
//  : 段落字下げ2 ← ( ( 改行天付き / 天字下げ / 文字下げ / 文字下げ２ ) "\n" ブロック２ * )
ParaIndent2 = ( ( NewlineTentsuki / LeftIndent / IndentBegin / IndentBegin2 ) "\n" Block2 * )
//  : 改行天付き ← "［＃ここから改行天付き、折り返して" 数 "字下げ］"
NewlineTentsuki = "［＃ここから改行天付き、折り返して" Number "字下げ］"
//  : 天字下げ ← "［＃天から" 数 "字下げ］"
LeftIndent = "［＃天から" Number "字下げ］"
//  : 文字下げ ← "［＃ここから" 数 "字下げ］"
IndentBegin = "［＃ここから" Number "字下げ］"
//  : 文字下げ２ ← "［＃ここから" 数 "字下げ、折り返して" 数 "字下げ］"
IndentBegin2 = "［＃ここから" Number "字下げ、折り返して" Number "字下げ］"
//  : 字下げ終 ← "［＃ここで字下げ終わり］"
IndentEnd = "［＃ここで字下げ終わり］"
//  : 段落字詰め ← ( "［＃ここから" 数 "字詰め］\n" ブロック * "［＃ここで字詰め終わり］")
ParaJizume = ( "［＃ここから" Number "字詰め］\n" Block * "［＃ここで字詰め終わり］")
//  : 段落地付き ← ( "［＃ここから地付き］\n" ブロック * "［＃ここで地付き終わり］" )
ParaChitsuki = ( "［＃ここから地付き］\n" Block * "［＃ここで地付き終わり］" )
//  : 段落字上げ ← ( "［＃ここから地から" 数 "字上げ］\n" ブロック * "［＃ここで字上げ終わり］" )
ParaNegativeIndent  = ( "［＃ここから地から" Number "字上げ］\n" Block * "［＃ここで字上げ終わり］" )
//  : 段落字体 ← ( "［＃ここから" 字体 "］\n" ブロック * "［＃ここで" 字体 "終わり］" )
ParaJitai = ( "［＃ここから" Jitai "］\n" Block * "［＃ここで" Jitai "終わり］" )
//  : 段落文字大 ← ( "［＃ここから" 数 "段階大きな文字］\n" ブロック * "［＃ここで大きな文字終わり］" )
ParaLargeChar = ( "［＃ここから" Number "段階大きな文字］\n" Block * "［＃ここで大きな文字終わり］" )
//  : 段落文字小 ← ( "［＃ここから" 数 "段階小さな文字］\n" ブロック * "［＃ここで小さな文字終わり］" )
ParaSmallChar = ( "［＃ここから" Number "段階小さな文字］\n" Block * "［＃ここで小さな文字終わり］" )
//  : 段組み ← ( "［＃ここから" 数 "段組み" "、段間に罫" ? "］\n" ブロック * "［＃ここで段組み終わり］" )
Column = ( "［＃ここから" Number "段組み" "、段間に罫" ? "］\n" Block * "［＃ここで段組み終わり］" )

/***
* 制約条件

  - 「囲み注記」 の開始・終了注記の字体修飾指定は一致しなければなりません。
  - 「修飾注記・原文注記等・原文注記・入力者注記・底本注記・左ルビ」に
    おける「引用文字列」は、その直前の本文文字列と、注記表記の有無のい
    ずれかで一致しなければなりません。
 ***/
