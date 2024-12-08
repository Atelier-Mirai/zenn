---
title: "Vivliostyle Flavored Markdownでソースコードを取り込む"
emoji: "🎉"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Ruby", "CSS組版", "vivliostyle", "Markdown", "技術書典"]
published: true
published_at: 2024-12-08 18:30
---

## はじめに

[Vivliostyle Flavored Markdownでコードに行番号を付ける](https://zenn.dev/atelier_mirai/articles/vivliostyle_line_numbers/) の続編になります。

## Vivliostyle Flavored Markdownでソースコードを取り込む

プログラミングに関する技術書には、ソースコードの掲載が不可欠です。普通は次のようにソースコードを直接```Markdown```中に記述することとなります。

~~~markdown
```ruby:prime.rb
def prime?(num)
  return false if num <= 1
  (2..Math.sqrt(num)).none? { |i| num % i == 0 }
end

primes = (1..100).select { |num| prime?(num) }
puts primes
```
~~~

そして、既にソースファイルが存在する場合、コピー＆ペーストで貼り付けるのは手間です。そこで、**ソースコードを取り込む機能**を実装したいと思います。

## 仕様

### include文
まず、**ソースコードを取り込む機能** についてですが、```include``` や ```import``` と呼ばれることが多いです。
ここでは、```C言語```に倣って ```include``` を用いることにします。


### HonKit
次に、```include```文の記法についてです。```Markdown```での書籍執筆ツールとして[HonKit](https://honkit.netlify.app) も有名です。

```HonKit```では、次のように書くことで、```source```ディレクトリの```prime.rb```を取り込むことができます。

~~~markdown
[include](source/prime.rb)
~~~

### Block Code

一般的な ```markdown``` に倣って、次のように書くことも自然な拡張のように思えます。言語名```ruby``` に代えて、```include```文であることを示しています。

~~~markdown
```include:source/prime.rb
```
~~~

### One Line

```include```文に必要なのは、\`\`\`include: source/prime.rb\`\`\` のみですから、前後の\`\`\` を外して、以下のように書けるとよりスマートかもしれません。

~~~markdown
include: source/prime.rb
~~~

ということで、好みもあるかと思いますので、以上の ```HonKit```、```Block code```、```One Line```に対応した ```include```機能を実装したいと思います。

## アルゴリズム

1. 元の```Markdown```ファイルを読み込む。
2. 一行ずつ走査して
       ```include```文が書かれていたら、
      　　ソースコードを読み込んで、ファイルに書き込む
      書かれていなかったら
      　　各行をそのままファイルに書き込む

## コード

以上の方針を踏まえて、完成したコードは次のようになります。

```ruby:include.rb
# 取り込み前
# HonKit
# [include](prime.rb)
# Block Code
# ```include:prime.rb
# ```
# One Line
# include: prime.rb

# 取り込み後
# ```ruby:prime.rb
# def prime?(num)
#   return false if num <= 1
#   (2..Math.sqrt(num)).none? { |i| num % i == 0 }
# end
#
# primes = (1..100).select { |num| prime?(num) }
# puts primes
# ```

# 拡張子と言語との対応ハッシュ
hash = { rb:   "ruby",
         html: "html",
         css:  "css",
         js:   "javascript",
         c:    "c",
         java: "java" }

# ソースコードを読み込む
def load_source_file(path)
  begin
    File.read(path)
  rescue Errno::ENOENT => e
    # ソースコードが読み込めなかった場合の例外発生時
    puts "ファイルが開けませんでした: #{e.message}"
    false
  end
end

# 読み込みファイル名
input_file = ARGV[0]

# 主ファイル名と拡張子
basename = File.basename(ARGV[0], ".*")
extname  = File.extname(ARGV[0])
# 書き込みファイル名
output_file = "_i_#{basename}#{extname}"

# 置換後のMarkdownをファイルに書き込む
File.open(output_file, "w") do |file|
  # ファイルを読み込む
  content = File.read(input_file)
  content.each_line do |line|
    # [include](source/prime.rb)
    # ```include:prime.rb
    # include: prime.rb
    # に一致すれば、prime.rb を読み込む
    if match = line.match(/include:\s*([a-zA-Z0-9_\/\.\-]+)/) ||
               line.match(/\[include\]\(([a-zA-Z0-9_\/\.\-]+)\)/)
      path          = match[1]                                # パス名
      directory     = File.dirname(path)                      # ディレクトリ名
      main_filename = File.basename(path, File.extname(path)) # 主ファイル名
      extension     = File.extname(path).delete('.')          # 拡張子を取得
      filename      = "#{main_filename}.#{extension}"         # ファイ名
      language      = hash[extension.to_sym]                  # 言語名
      file.puts "```#{language}:#{filename}"
      if source = load_source_file(path)
        file.puts source
      else
        file.puts "=== Could not open the source file ==="
      end

      # コードブロックの不足があれば補う
      file.puts "```" unless line.match(/```/)
    else
      file.puts line
    end
  end
end
```

## 実行結果

```sample.rb``` として、次の ```Markdown```を用意します。

~~~markdown
---
lang: ja
link:
  - rel: 'stylesheet'
    href: 'prism.css'
---

# include 練習

```include```の練習です。

## Ruby
```ruby:prime.rb
def prime?(num)
  return false if num <= 1
  (2..Math.sqrt(num)).none? { |i| num % i == 0 }
end

primes = (1..100).select { |num| prime?(num) }
puts primes
```

## HonKit
[include](source/prime.rb)

## Block Code
```include:source/prime.rb
```

## One Line
include: source/prime.rb
~~~

次のコマンドで実行します。

```zsh
$ ruby include.rb sample.md
```

```_i_sample.md```として、次のように```markdown```ファイルが出力されています。

~~~markdown
---
lang: ja
link:
  - rel: 'stylesheet'
    href: 'prism.css'
---

# include 練習

```include```の練習です。

## Ruby
```ruby:prime.rb
def prime?(num)
  return false if num <= 1
  (2..Math.sqrt(num)).none? { |i| num % i == 0 }
end

primes = (1..100).select { |num| prime?(num) }
puts primes
```

## HonKit
```ruby:prime.rb
def prime?(num)
  return false if num <= 1
  (2..Math.sqrt(num)).none? { |i| num % i == 0 }
end

primes = (1..100).select { |num| prime?(num) }
puts primes
```

## Block Code
```ruby:prime.rb
def prime?(num)
  return false if num <= 1
  (2..Math.sqrt(num)).none? { |i| num % i == 0 }
end

primes = (1..100).select { |num| prime?(num) }
puts primes
```

## One Line
```ruby:prime.rb
def prime?(num)
  return false if num <= 1
  (2..Math.sqrt(num)).none? { |i| num % i == 0 }
end

primes = (1..100).select { |num| prime?(num) }
puts primes
```
~~~

無事に、```source```ディレクトリの```prime.rb```ファイルを取りこめたことが分かります。

出力結果の ```_i_sample.md``` は作業用です。不要になったら、次のコマンドで削除できます。

```zsh
rm _i_sample.md
```

## 行番号表示と組み合わせる

ソースコードを読み込むことができましたので、前回行った行番号表示と組み合わせましょう。

前回の最後に登場した ```vfm2html.rb```を次のように少し書き換えます。

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
  temporary_file = "_i_#{file}.md"
  command = <<~CMD
    ruby include.rb #{file}.md
    vfm #{temporary_file} > #{file}.html
    ruby line_numbers.rb #{file}.html
  CMD

  # コマンドを実行する
  output = `#{command}`
  # 作業ファイルを削除する
  File.delete(temporary_file)
end

# 結果を表示
puts "Markdownから、行番号付きHTMLへの変換が完了しました。"
```

```zsh
$ ./vfm2html.rb sample.md
```

```sample.md``` から ```sample.html``` が作成されましたので、```Vivliostyle```で表示結果を確認してみましょう。

```zsh
$ vivliostyle preview sample.html
```

![](https://storage.googleapis.com/zenn-user-upload/74a55d907f9f-20241208.png)

ソースコードを取り込み、行番号付きで表示することができました。

## おまけ

```vivliostyle preview``` の際には、元の```markdown```ファイルではなく、加工後の ```html``` を参照したいことと思います。 そこで、```vivliostyle.config.js``` の内容を少し更新しましょう。

前回は ```markdown```ファイルをプレビューしたので、```entry```ファイルの拡張子が```.md```になっていましたが、```.html```に更新します。

```javascript:vivliostyle.config.js
// @ts-check
/** @type {import('@vivliostyle/cli').VivliostyleConfigSchema} */
const vivliostyleConfig = {
  title: 'Rubyの世界: 初心者のためのプログラミング入門',
  author: 'アトリヱ未來',
  image: 'ghcr.io/vivliostyle/cli:8.17.1',
  entry: [
    "00-introduction.html",
    "01-basics-of-ruby.html",
    "02-setting-up.html",
    "03-control-structures.html",
    "04-using-ethods.html",
    "05-data-structures.html",
    "06-object-oriented-programming.html",
    "07-error-handling.html",
    "08-ruby-standard-library.html",
    "09-simple-projects.html",
    "10-next-steps.html",
    "11-appendix.html"
  ],
};

module.exports = vivliostyleConfig;
```

これで、以下のコマンドを実行することで、更新した ```Markdown```ファイルの内容を確認することができるようになりました。

```zsh
$ ./vfm2html.rb
$ vivliostyle preview
```

## 終わりに

```CSS組版```として人気の```Vivliostyle```で、ソースコードの行番号表示とソースコードの取り込みができるようになりました。電子書籍や印刷物を簡単に作ることができます。お役に立てば幸いです。
