---
title: "Vivliostyle Flavored Markdownでコードに行番号を付ける"
emoji: "🎉"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Ruby", "CSS組版", "vivliostyle", "Markdown", "技術書典"]
published: true
published_at: 2024-12-07 18:30
---

## はじめに

```CSS組版```は、ウェブ制作技術を用いて書籍を執筆するものです。本文を```HTML / Markdown```で、ページレイアウトや装飾には```CSS```を用います。通常のウェブ制作と（ほぼ）同様ですので、```LaTeX```や```InDesign```を習得するよりも容易に、書きたいものを書いて、書籍化することができます。

```CSS組版``` を行うツールはいくつかございますが、[Vivliostyle](https://vivliostyle.org/ja/)はオープンソースで開発が行われているツールで、電子書籍から印刷物まで多くの活用事例がございます。

公式サイトの他、『[Web技術で「本」が作れるCSS組版Vivliostyle入門](https://www.c-r.com/book/detail/1493)』でも紹介されておりますので、ご覧下さい。


## ```Vivliostyle```のインストールと簡単な使い方

公式サイトよりの抜粋です。

### インストール
```zsh
$ npm install -g @vivliostyle/cli
$ npm install -g @vivliostyle/vfm
```

### 簡単な使い方

#### 初期化
```zsh
$ mkdir mybook
$ cd mybook
$ vivliostyle init
```

```mybook```ディレクトリ直下に ```vivliostyle.config.js```ファイルが作られます。
コメントを除くと次のようになっています。```title```には書籍名を、```author```には著者名を、```entry```配列には執筆する各章の```Markdown```ファイルを記述します。[^章立て]

[^章立て]: ```Markdown```ファイル名は任意ですが、```"00-introduction.md"```のように先頭に数字をつけておくと、順番に並ぶので便利です。

```javascript:vivliostyle.config.js
// @ts-check
/** @type {import('@vivliostyle/cli').VivliostyleConfigSchema} */
const vivliostyleConfig = {
  title: 'Rubyの世界: 初心者のためのプログラミング入門',
  author: 'アトリヱ未來',
  image: 'ghcr.io/vivliostyle/cli:8.17.1',
  entry: [
    "00-introduction.md",
    "01-basics-of-ruby.md",
    "02-setting-up.md",
    "03-control-structures.md",
    "04-using-ethods.md",
    "05-data-structures.md",
    "06-object-oriented-programming.md",
    "07-error-handling.md",
    "08-ruby-standard-library.md",
    "09-simple-projects.md",
    "10-next-steps.md",
    "11-appendix.md"
  ],
};

module.exports = vivliostyleConfig;
```

#### Vivliostyle Flavored Markdown で執筆する

通常のMarkdownから、書籍の執筆がしやすくなるよう、```Frontmatter（フロントマター）```の追加など、少し拡張されています。(例は後ほど掲載します)


#### プレビュー

```Chromium```ブラウザが起動し、執筆内容を確認できます。

```zsh
# 全章を通してのプレビュー
$ vivliostyle preview

# 特定のMarkdownファイルを選択してのプレビュー
$ vivliostyle preview 00-introduction.md

# Markdownからhtmlへの変換
$ vfm 00-introduction.md > 00-introduction.html

# 特定のhtmlファイルを選択してのプレビュー
$ vivliostyle preview 00-introduction.html
```

#### PDFファイルの作成

```vivliostyle build```で PDFファイルを生成できます。様々なオプションを指定できますが、わたくしは次のようにしています。

```zsh
$ vivliostyle build --preflight press-ready-local
```





## ソースコードに行番号を付ける先行事例のご紹介

プログラミングに関する技術書には、ソースコードの掲載が不可欠です。また、構文強調表示（シンタックスハイライト）は不可欠ではありませんが、あると嬉しい機能です。

```Vivliostyle Flavored Markdown(VFM)```では、```Prism``` に対応した構文強調表示ができるよう、```Markdown```から```HTML```に変換してくれるので、```<link rel="stylesheet" href="prism.css">``` と ```prism.css``` を読み込むことで、構文強調表示ができます。

行番号も表示されると良いのですが、『[Web技術で「本」が作れるCSS組版Vivliostyle入門](https://www.c-r.com/book/detail/1493)』の162頁には、次のように書かれております。

> ソースコードに行番号を付けるのは、CSSだけではできません。

なんとか、番号をつける方法は無いものかと、調べたところ、[@u1f992(Koutaro Mukai)さん](https://qiita.com/u1f992)の以下の記事を見つけました。

https://qiita.com/u1f992/items/b30dfbee13ab47dcfdea

```Vivliostyle Flavored Markdown(VFM)```のソースコードをダウンロード、```vfm```コマンドを拡張することにより、```Prism```に対応した行番号を付与する方法です。

```vfm```コマンドの改修が少し手間だったのと、わたくしの愛する```Ruby```では行番号は付与されるものの、構文強調表示が為されなかったことから、他の方法はないか、考えてみました。[^0]

[^0]: ```HTML / CSS / JavaScript``` は行番号、構文強調表示ともにされました。

## 生成されたHTMLを眺めてみる

次のコードは ```Vivliostyle Flavored Markdown(VFM)``` で書いた ```Markdown```の例です。通常の```Markdown```に加え、```Frontmatter（フロントマター）```と呼ばれる付加情報を記述できる点が特徴です。[^1]

[^1]: 余談ですが、コード例は生成AI [wrtn(リートン)](https://wrtn.jp) に因るものです。


~~~markdown:prime.md
---
lang: ja
link:
  - rel: 'stylesheet'
    href: 'prism.css'
---

# Prismでの行番号表示

```Ruby``` での素数を求めるコード例です。

## Ruby

```ruby:prime.rb
def prime?(num)
  return false if num <= 1
  (2..Math.sqrt(num)).none? { |i| num % i == 0 }
end

primes = (1..100).select { |num| prime?(num) }
puts primes
```

~~~

```vfm```コマンドで、```Markdown```を```HTML```に変換します。

```zsh
$ vfm prime.md > prime.html
```

すると、次の```HTML```ファイルが得られます。[^2]
[^2]: インデントが気になりますが、```Ruby```ソースコードの為の余白ですので、このままにしておきます。


```html:prime.html
<!doctype html>
<html lang="ja">
  <head>
    <meta charset="utf-8">
    <title>Prismでの行番号表示</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="prism.css">
  </head>
  <body>
    <section class="level1" aria-labelledby="prismでの行番号表示">
      <h1 id="prismでの行番号表示">Prismでの行番号表示</h1>
      <p><code>Ruby</code> での素数を求めるコード例です。</p>
      <section class="level2" aria-labelledby="ruby">
        <h2 id="ruby">Ruby</h2>
        <figure class="language-ruby">
          <figcaption>prime.rb</figcaption>
          <pre class="language-ruby"><code class="language-ruby"><span class="token keyword">def</span> <span class="token method-definition"><span class="token function">prime</span></span><span class="token operator">?</span><span class="token punctuation">(</span>num<span class="token punctuation">)</span>
  <span class="token keyword">return</span> <span class="token boolean">false</span> <span class="token keyword">if</span> num <span class="token operator">&#x3C;=</span> <span class="token number">1</span>
  <span class="token punctuation">(</span><span class="token number">2.</span><span class="token punctuation">.</span>Math<span class="token punctuation">.</span>sqrt<span class="token punctuation">(</span>num<span class="token punctuation">)</span><span class="token punctuation">)</span><span class="token punctuation">.</span>none<span class="token operator">?</span> <span class="token punctuation">{</span> <span class="token operator">|</span>i<span class="token operator">|</span> num <span class="token operator">%</span> i <span class="token operator">==</span> <span class="token number">0</span> <span class="token punctuation">}</span>
<span class="token keyword">end</span>

primes <span class="token operator">=</span> <span class="token punctuation">(</span><span class="token number">1.</span><span class="token number">.100</span><span class="token punctuation">)</span><span class="token punctuation">.</span>select <span class="token punctuation">{</span> <span class="token operator">|</span>num<span class="token operator">|</span> prime<span class="token operator">?</span><span class="token punctuation">(</span>num<span class="token punctuation">)</span> <span class="token punctuation">}</span>
puts primes</code></pre>
        </figure>
      </section>
    </section>
  </body>
</html>
```


構文強調表示の為に、[Prism](https://prismjs.com/download.html)から```line-numbers```プラグインを有効にしたCSSをダウンロードし、これを```Vivliostyle```でプレビューすると次のようになります。

```zsh
$ vivliostyle preview prime.html
```

![](https://storage.googleapis.com/zenn-user-upload/6d59a9a160ef-20241207.png)

標準の```vfm```では、構文強調表示は行われるが行番号は付かないことが分かります。

## 行番号を付ける為の調査

どのようにすれば、行番号が付与されるのか、[@u1f992(Koutaro Mukai)さん](https://qiita.com/u1f992) の```html```出力を見たところ、次のようにすれば良いことが分かりました。[^3]

[^3]:分かりやすいよう、整形してあります。

```html:行番号無し
<pre class="language-ruby">
  <code class="language-ruby">
    (素数コード例)
  </code>
</pre>
```

```html:行番号有り
<pre class="language-ruby line-numbers">
  <code class="language-ruby line-numbers">
    (素数コード例)
    <span aria-hidden="true" class="line-numbers-rows">
      <span></span>
      <span></span>
      <span></span>
      <span></span>
      <span></span>
      <span></span>
      <span></span>
    </span>
  </code>
</pre>
```

 * ```<pre>```タグと```<code>```タグに ```line-numbers```クラスを付与する
 * ```<code>```タグの終わりに```<span>```タグを追加する
 * ```<span>```タグの個数は、素数コード例の行数に等しい

ですので、これを実現する為に、```vfm```が生成した```html```コードを加工することを考えます。

## 行番号を付与する為の```Ruby```コード

```HTML```の解析や加工処理を行うには、```Nokogiri（ノコギリ）```が定番です。```Nokogiri（ノコギリ）```を使って、行番号を追加するコードを書くと次のようになります。

```ruby:line_numbers.rb
require "open-uri"
require 'nokogiri'

# 使い方表示
if ARGV.size == 0
  puts <<~USAGE
    Code to modify an HTML file so that line numbers are displayed with Prism.
    usage: #{File.basename(__FILE__)} filename.html
  USAGE
  exit 1
end

# HTMLを読み込む
doc = Nokogiri::HTML.parse(URI.open(ARGV[0]))

# <pre>要素を取得
pre_tags = doc.css("pre")

# コードの行数を返す
def line_count(pre)
  pre.text.count("\n") + 1
end

# 各preタグについて、加工処理を行う
pre_tags.each do |pre|
  # クラス名付与
  pre[:class] += " line-numbers"
  code = pre.css("code").first
  cloned_code = code.clone
  cloned_code[:class] += " line-numbers"

  # 行番号の為の <span>要素を作成
  span = Nokogiri::XML::Node.new("span", doc)
  span["aria-hidden"] = "true"
  span["class"] = "line-numbers-rows"

  # <span></span>要素を、コードの行数分追加する。
  line_count(pre).times do
    span_line = Nokogiri::XML::Node.new('span', doc)
    span.add_child(span_line)
  end
  # でき上がった<span>要素
  # puts span #=> <span aria-hidden="true" class="line-numbers-rows"><span></span><span></span><span></span></span>

  # <code>要素の末尾に追加する
  cloned_code.add_child(span)

  # 元の<code>要素に代え、新しい<code>要素で置換する
  code.replace(cloned_code)
end

# 変更後のHTMLをファイルに書き込む
File.open(ARGV[0], "w") do |file|
  file.puts doc.to_html
end
```

それでは、コマンドラインで実行してみます。

~~~zsh
$ vfm prime.md > prime.html
$ ruby line_numbers.rb prime.html
$ vivliostyle preview prime.html
~~~

プレビュー結果も行番号が付いています。
![](https://storage.googleapis.com/zenn-user-upload/29690cb166d5-20241207.png)

## 一括して変換する

先のコードで、行番号付き```html```に変換できるようになりました。何度もコマンドを実行するのは少し手間ですので、まとめてできるようにしてみます。次のようになります。

```ruby:vfm2html.rb
#!/usr/bin/env ruby

require "find"

# 変換対象ファイル
files = []

if ARGV.size != 0
  # 変換対象ファイルが指定されているなら当該ファイルを変換
  filename_without_extension = File.basename(ARGV[0], ".md")
  files << filename_without_extension
else
  # カレントディレクトリ直下の全てのMarkdownファイルを対象に変換
  directory = "."
  md_files = Dir.glob("#{directory}/*.md")
  md_files.each do |file|
    # 拡張子を取り除く
    filename_without_extension = File.basename(file, ".md")
    files << filename_without_extension
  end
end

# 変換対象ファイルへの繰り返し処理
files.each do |file|
  # 実行するコマンドを設定
  command = <<~CMD
    vfm #{file}.md > #{file}.html
    ruby line_numbers.rb #{file}.html
  CMD

  # コマンドを実行する
  output = `#{command}`
end

# 結果を表示
puts "Markdownから、行番号付きHTMLへの変換が完了しました。"
```

個別の```Markdown```ファイルを変換するには次のようにします。

```zsh
$ ruby vfm2html prime.md
```

カレントディレクトリの全ての```Markdown```ファイルを一括して変換するには次のようにします。

```zsh
$ ruby vfm2html.rb
```

実行属性を付けると、少しだけ短く実行することができます。
```zsh
$ chmod +x vfm2html.rb
```

```zsh
$ ./vfm2html.rb prime.md
$ ./vfm2html.rb
```

## 終わりに

```CSS組版```として人気の```Vivliostyle```で、ソースコードの行番号を付与することができるようになりました。電子書籍や印刷物を簡単に作ることができます。お役に立てば幸いです。
