#!/usr/bin/env ruby

require "json"

SOURCE_NAME = "《王兴饭否动态合集》全文提取"
SOURCE_URL = "https://fanfou.com/wangxing"

TAG_RULES = {
  "创业" => %w[创业 创业者 创投],
  "商业" => %w[商业 生意 市场 行业 品牌 服务 客户 用户 公司 企业],
  "管理" => %w[管理 CEO 组织 团队 员工 人才 领导],
  "投资" => %w[投资 资本 股市 基金 估值],
  "竞争" => %w[竞争 对手 输赢 胜利 失败],
  "科技" => %w[科技 技术 互联网 软件 算法 数字 电脑 手机],
  "个人成长" => %w[成长 学习 能力 勇气 坚持 放弃 责任],
  "思维方式" => %w[思考 认知 本质 逻辑 问题 答案 选择],
  "认识世界" => %w[世界 社会 历史 文化 经济 人类 未来]
}.freeze

def normalize(text)
  text.downcase.gsub(/[[:space:][:punct:]，。！？；：“”‘’「」『』（）《》…—]/, "")
end

def clean_body(body)
  body
    .delete("\u0000")
    .gsub(/^第\s+\d+\s+页\s+\/\s+共\s+\d+\s+页\s*$\n?/, "")
    .gsub(/^www\.hackersay\.com\s*$\n?/, "")
    .strip
end

def clean_text(text)
  text
    .gsub(/(?<=\p{Han})\s+(?=\p{Han})/, "")
    .gsub(/\s+/, " ")
    .strip
end

source_path, target_path = ARGV
abort "用法: ruby Scripts/import_fanfou_fulltext.rb <全文提取.txt> <XingQuotes.json>" unless source_path && target_path

source = File.read(source_path, encoding: "UTF-8", invalid: :replace, undef: :replace)
quotes = JSON.parse(File.read(target_path, encoding: "UTF-8"))
known = quotes.to_h { |quote| [normalize(quote.fetch("text")), true] }
headings = source.enum_for(:scan, /^(\d+)\.\s*$/).map do
  [Regexp.last_match(1).to_i, Regexp.last_match.begin(0), Regexp.last_match.end(0)]
end

entries = headings.each_with_index.map do |(number, _heading_start, body_start), index|
  body_end = index + 1 < headings.length ? headings[index + 1][1] : source.length
  body = clean_body(source[body_start...body_end])
  metadata = body.match(/^(\d{4}-\d{2}-\d{2}) \d{2}:\d{2}[^\n]*$/)
  text_end = metadata ? metadata.begin(0) : body.length
  text = clean_text(body[0...text_end])
  next if text.empty?

  [number, text, metadata&.[](1)]
end.compact

next_id = quotes.map { |quote| quote.fetch("id").delete_prefix("xing-").to_i }.max.to_i + 1
added = 0

entries.each do |number, text, date|
  normalized = normalize(text)
  next if normalized.empty? || known.key?(normalized)

  tags = TAG_RULES.map do |tag, words|
    tag if words.any? { |word| text.downcase.include?(word.downcase) }
  end.compact.first(2)
  tags = ["日常"] if tags.empty?

  quotes << {
    "id" => format("xing-%04d", next_id),
    "text" => text,
    "author" => "王兴",
    "platform" => "饭否",
    "tags" => tags,
    "sources" => [
      {
        "name" => SOURCE_NAME,
        "url" => SOURCE_URL,
        "sourceNumber" => number,
        "date" => date
      }.compact
    ]
  }
  known[normalized] = true
  next_id += 1
  added += 1
end

File.write(target_path, JSON.pretty_generate(quotes) + "\n")
puts "已解析 #{entries.length} 条编号动态，去重后新增 #{added} 条。"
puts "当前 App 语录总数：#{quotes.length}"
