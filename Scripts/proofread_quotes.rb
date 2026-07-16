#!/usr/bin/env ruby

require "json"

TEXT_OVERRIDES = {
  "xing-0034" => "米开朗基罗谈到自己著名的作品「大卫」雕像时曾说：「并不是我创造了大卫，他本来就在石头中，我只是把多余的石头敲掉。」那些以为自己发明了牛逼商业模式或产品的人，都应该参考一下米开朗基罗的谦逊和洞见。",
  "xing-0182" => "意大利有个女探险家独自穿越了塔克拉玛干沙漠。当她走出沙漠后，她面对沙漠跪下来静默良久。当有记者问她在征服沙漠后为何下跪时，她极为真诚地说：「我不认为我征服了沙漠，我是在感谢塔克拉玛干允许我通过。」我一直觉得，喜欢幻想对抗关系的人是傻缺。",
  "xing-0203" => "塞缪尔·约翰逊（Samuel Johnson）在他的寓言《拉塞拉斯》（1759）中写道：“真相就是，没有人能专注于当下：回忆和预期几乎充斥了每时每刻。”",
  "xing-0221" => "所以，真正的下一代人机交互界面必须是眼镜，而不是智能音箱。视觉艺术心理学家鲁道夫·阿恩海姆曾谈到：“光线，几乎是人的感官所能得到的一种最辉煌、最壮观的经验。”",
  "xing-0225" => "很美。但是有事实性错误，把日地距离说小了一万倍。转发内容：良久，他开口：“在夜里，我们看得比白天更远。”“白天只能看到一万五千公里外的太阳，夜里却能看到百万光年外的星系。”"
}.freeze

REPLACEMENTS = {
  "年轻是把时间" => "年轻时把时间",
  "Coarse" => "Coase",
  "li nkedin" => "LinkedIn",
  "li nkedIn" => "LinkedIn",
  "InformationTechnology" => "Information Technology",
  "标志在法国" => "标致在法国",
  "水份" => "水分",
  "付费帐号" => "付费账号",
  "转@王兴" => "",
  "埃德蒙.柏克" => "埃德蒙·柏克",
  "马克. 安德森" => "马克·安德森",
  "Photo Libary" => "Photo Library",
  "iCloudStorage" => "iCloud Storage",
  "（a tried）" => "（a triad）",
  "解决的的硬件挑战" => "解决的硬件挑战",
  "8O后" => "80后",
  "美国风险投资人家 Aileen Lee" => "美国风险投资人 Aileen Lee",
  "elon musk" => "Elon Musk",
  "google深谙" => "Google 深谙",
  "jonathan ive" => "Jonathan Ive",
  "visio" => "Visio",
  "Eat Better,Live Better." => "Eat Better, Live Better. ",
  "amazon books" => "Amazon Books",
  "palo alto" => "Palo Alto",
  "rosewood瑰丽酒店" => "Rosewood 瑰丽酒店",
  "paul graham" => "Paul Graham",
  "asana" => "Asana",
  "chrome浏览器" => "Chrome 浏览器",
  "23andme" => "23andMe",
  "home键" => "Home 键",
  "qwerty键盘" => "QWERTY 键盘",
  "基因gene" => "基因 gene",
  "媒母meme" => "媒母 meme",
  "科斯Coase" => "科斯 Coase"
}.freeze

def normalize_typography(text)
  value = text.tr("\u00a0", " ")
  value = value.gsub(/(?<=\p{Han})\s+(?=\p{Han})/, "")
  value = value.gsub(/\s+([，。！？；：」』”）])/, "\\1")
  value = value.gsub(/([「『“（])\s+/, "\\1")
  value = value.gsub(/([，。！？；：])\s+(?=\p{Han})/, "\\1")
  value = value.gsub(/(?<=[\p{Han}」』”）]):/, "：")
  value = value.gsub(/(?<=[\p{Han}」』”）]);/, "；")
  value = value.gsub(/(?<=[\p{Han}」』”）]),/, "，")
  value = value.gsub(/(?<=[\p{Han}」』”）])\?/, "？")
  value = value.gsub(/(?<=[\p{Han}」』”）])!/, "！")
  value = value.gsub(/\.\.\.+/, "……")
  value = value.gsub(/\s+。/, "。")
  value.strip
end

def balance_quotes(text, opening, closing)
  opens = text.count(opening)
  closes = text.count(closing)
  return opening + text if closes == opens + 1
  return text + closing if opens == closes + 1

  text
end

path = ARGV.first
abort "用法: ruby Scripts/proofread_quotes.rb <XingQuotes.json>" unless path

quotes = JSON.parse(File.read(path, encoding: "UTF-8"))
changed = 0
dates_extracted = 0

quotes.each do |quote|
  before = quote.fetch("text")
  text = TEXT_OVERRIDES.fetch(quote.fetch("id"), before)
  REPLACEMENTS.each { |from, to| text = text.gsub(from, to) }
  text = normalize_typography(text)
  text = balance_quotes(text, "「", "」")
  text = balance_quotes(text, "“", "”")
  quote["text"] = text
  changed += 1 if text != before

  quote.fetch("sources", []).each do |source|
    match = source.fetch("name", "").match(/（(\d{4}-\d{2}-\d{2})）/)
    next unless match

    source["name"] = source.fetch("name").sub(match[0], "")
    source["date"] ||= match[1]
    dates_extracted += 1
  end
end

File.write(path, JSON.pretty_generate(quotes) + "\n")
puts "已校对 #{quotes.length} 条饭否语录，修正 #{changed} 条。"
puts "已整理 #{dates_extracted} 条原始发布日期。"
