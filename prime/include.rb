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
