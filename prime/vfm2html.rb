#!/usr/bin/env ruby

require "find"

files = []
if ARGV.size != 0
  filename_without_extension = File.basename(ARGV[0], ".md")
  files << filename_without_extension
else
  # 対象のディレクトリを指定（例：カレントディレクトリ）
  directory = "."
  # ディレクトリ内のMarkdownファイルを列挙して表示
  md_files = Dir.glob("#{directory}/*.md")
  # Markdownファイル名を取得
  md_files.each do |file|
    # 拡張子を取り除く
    filename_without_extension = File.basename(file, ".md")
    files << filename_without_extension
  end
end

files.each do |file|
  # 実行するコマンドを指定
  command = <<~CMD
    vfm #{file}.md > #{file}.html
    ruby line_numbers.rb #{file}.html
  CMD

  # コマンドを実行し、出力を取得
  output = `#{command}`
end

# 結果を表示
puts "Markdownから、行番号付きHTMLへの変換が完了しました。"
