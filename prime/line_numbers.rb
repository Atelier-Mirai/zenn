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
