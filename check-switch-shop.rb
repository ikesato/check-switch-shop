#!/usr/bin/env ruby
# coding: utf-8
$LOAD_PATH.push File.dirname(File.expand_path($0))
require 'omni7'
require 'toysrus'
require 'amazon'
require 'rakuten_books'
require 'yamada'
require 'ito_yokado'
require 'nojima'

shops = [
  {crawler: Omni7.new,        name: "オムニ7"},
  {crawler: Toysrus.new,      name: "トイザラス"},
  {crawler: Amazon.new,       name: "Amazon"},
  {crawler: RakutenBooks.new, name: "楽天ブックス"},
  {crawler: Yamada.new,       name: "ヤマダ"},
  {crawler: ItoYokado.new,    name: "イトーヨーカドー"},
  {crawler: Nojima.new,       name: "ノジマ"},
]

errors = []
availables = shops.map do |s|
  begin
    r = s[:crawler].check
    r ? {detail: r, name: s[:name]} : nil
  rescue => ex
    errors << ex
    nil
  end
end.compact

errors.each do |ex|
  STDERR.puts ex
  STDERR.puts ex.backtrace
  STDERR.puts ""
end


if availables.length > 0
  text = ["販売中！急げ！", ""]
  text << availables.map do |a|
    "- #{a[:name]}\n" + a[:detail].join("\n")
  end.join("\n")
  puts text.join("\n")
  exit 0
end

puts "在庫なし"
exit 1
