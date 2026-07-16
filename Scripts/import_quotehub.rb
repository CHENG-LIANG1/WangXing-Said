#!/usr/bin/env ruby

require "json"

SOURCE_URL = "https://github.com/DarinRowe/QuoteHub/blob/main/wang-xing/quotes.md"
SOURCE_NAME = "QuoteHub《王兴饭否动态合集》"
MAX_IMPORTS = 260

KEYWORDS = %w[
  创业 公司 商业 战略 管理 竞争 组织 团队 产品 用户 市场 资本 投资
  技术 互联网 企业 领导 学习 思考 认知 能力 机会 成功 失败 决策 效率
  长期 未来 世界 人生 人类 社会 历史 文化 经济 科学 创新 变化 价值 选择
  问题 解决 本质 规律 复杂 简单 好奇 自由 责任 时间 信息 教育 工作 行业
  品牌 服务 增长 边界 核心
].freeze

THOUGHT_PATTERNS = %w[
  如果 只有 没有 不是 应该 需要 不能 不要 往往 总是 意味着 越 最重要 真正
  任何 所有
].freeze

TAG_RULES = {
  "创业" => %w[创业 创业者 创投],
  "商业" => %w[商业 生意 市场 行业 品牌 服务 客户 用户],
  "管理" => %w[管理 CEO 组织 团队 员工 人才 领导],
  "投资" => %w[投资 资本 股市 基金 估值],
  "竞争" => %w[竞争 对手 输赢 胜利 失败],
  "科技" => %w[科技 技术 互联网 软件 算法 数字],
  "个人成长" => %w[成长 学习 能力 勇气 坚持 放弃 责任],
  "思维方式" => %w[思考 认知 本质 逻辑 问题 答案 选择],
  "认识世界" => %w[世界 社会 历史 文化 经济 人类 未来]
}.freeze

def normalize(text)
  text.downcase.gsub(/[[:space:][:punct:]，。！？；：“”‘’「」『』（）《》…—]/, "")
end

def score(text)
  value = KEYWORDS.sum { |keyword| text.scan(keyword).length * 3 }
  value += THOUGHT_PATTERNS.sum { |pattern| text.include?(pattern) ? 2 : 0 }
  value += 2 if text.count("，。！？；").positive?
  value += 2 if text.match?(/[。！？]$/)
  value -= 4 if text.match?(/(^|[，。])(?:今天|昨天|今晚|早上|中午|刚才|刚刚|终于|正在|吃|喝|买|到了|住在)/)
  value -= 4 if text.scan(/\d/).length >= 4
  value -= 3 if text.match?(/(?:iphone|android|ipad|google|facebook|twitter|微信|电影|机场|酒店)/i)
  value
end

def original_standalone_post?(text, metadata)
  return false if metadata.include?("转自")
  return false unless text.length.between?(12, 105) && text.match?(/[\p{Han}]/)

  blocked = /(?:转@|RT\s*@|https?:|www\.|!\[图片\]|@|转(?:自)?[:：]|作者\s*\/|#|——)/i
  attribution = /(?:朋友|同事|前辈|老师|专家|有人|他|她|嘉宾|大哥|同学|创始人|经济学家|作家).{0,18}(?:说|告诉|认为|回答|感慨|转述|讲|观点|建议)/
  return false if text.match?(blocked) || text.match?(attribution)
  return false if text.match?(/(?:短信|私信|引用).{0,16}(?:说|问|写|是)/)
  return false if text.match?(/[-—]\s*[\p{Han}A-Z][^,，。！？]{1,24}$/)
  return false if text.match?(/^[^:：]{1,12}[:：].{1,50}[^:：]{1,12}[:：]/)
  return false if text.match?(/(?:黑泽明|丘吉尔|巴菲特|索罗斯|德鲁克|鲍威尔).{0,20}(?:说|的)/)

  true
end


source_path, target_path = ARGV
abort "用法: ruby Scripts/import_quotehub.rb <quotes.md> <XingQuotes.json>" unless source_path && target_path

source = File.read(source_path, encoding: "UTF-8")
quotes = JSON.parse(File.read(target_path, encoding: "UTF-8"))
quotes.reject! do |quote|
  quote.fetch("sources", []).any? { |item| item.fetch("name", "").start_with?(SOURCE_NAME) }
end
original_count = quotes.length
known = quotes.map { |quote| normalize(quote.fetch("text")) }

entries = source.scan(/^### (\d+)\s*$\n\n(.*?)\n\n\*(\d{4}-\d{2}-\d{2}[^\n]*)\*$/m)
candidates = entries.map do |number, body, metadata|
  text = body
    .gsub(/(?<=\p{Han})\s+(?=\p{Han})/, "")
    .gsub(/\s+/, " ")
    .strip
  next unless original_standalone_post?(text, metadata)

  normalized = normalize(text)
  next if known.any? { |item| item == normalized || (item.length > 10 && normalized.length > 10 && (item.include?(normalized) || normalized.include?(item))) }

  value = score(text)
  next if value < 11

  [value, number.to_i, text, metadata[0, 10]]
end.compact

candidates.sort_by! { |value, number, _text, _date| [-value, number] }
next_id = quotes.map { |quote| quote.fetch("id").delete_prefix("xing-").to_i }.max + 1

candidates.first(MAX_IMPORTS).each do |_value, number, text, date|
  tags = TAG_RULES.map do |tag, words|
    tag if words.any? { |word| text.downcase.include?(word.downcase) }
  end.compact.first(2)
  tags = ["精选"] if tags.empty?

  quotes << {
    "id" => format("xing-%04d", next_id),
    "text" => text,
    "author" => "王兴",
    "platform" => "饭否",
    "tags" => tags,
    "sources" => [
      {
        "name" => "#{SOURCE_NAME}（#{date}）",
        "url" => "#{SOURCE_URL}##{number}",
        "sourceNumber" => number
      }
    ]
  }
  known << normalize(text)
  next_id += 1
end

File.write(target_path, JSON.pretty_generate(quotes) + "\n")
puts "已解析 #{entries.length} 条饭否动态，新增 #{quotes.length - original_count} 条。"
puts "当前 App 语录总数：#{quotes.length}"
