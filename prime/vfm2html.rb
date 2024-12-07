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
