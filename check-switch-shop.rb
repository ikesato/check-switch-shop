#!/usr/bin/env ruby
# coding: utf-8
$LOAD_PATH.push File.dirname(File.expand_path($0))
require 'optparse'
require 'omni7'
require 'toysrus'
require 'amazon'
require 'rakuten_books'
require 'yamada'
require 'ito_yokado'
require 'nojima'
require 'joshin'
require 'yodobashi'
require 'hmv'
require 'amiami'
require 'edion'

exfile=nil
htmloutdir=nil
OptionParser.new do |opt|
  opt.banner = "Usage: check-switch-shop.rb [options]"
  opt.separator ""
  opt.separator "Specific options:"
  opt.on("-e", "--exception-file=FILE") {|v|
    exfile = v
  }
  opt.on("-H", "--html-output-dir=DIR") {|v|
    htmloutdir = v
  }
  opt.parse!(ARGV)
end

shops = [
  {crawler: Omni7.new,        name: "オムニ7"},
  {crawler: Toysrus.new,      name: "トイザラス"},
  {crawler: Amazon.new,       name: "Amazon"},
  {crawler: RakutenBooks.new, name: "楽天ブックス"},
  {crawler: Yamada.new,       name: "ヤマダ"},
  {crawler: ItoYokado.new,    name: "イトーヨーカドー"},
  {crawler: Nojima.new,       name: "ノジマ"},
  {crawler: Joshin.new,       name: "ジョーシン"},
  {crawler: Yodobashi.new,    name: "ヨドバシ"},
  #{crawler: Hmv.new,          name: "ローチケHMV"},
  {crawler: Amiami.new,       name: "あみあみ"},
  {crawler: Edion.new,        name: "Edion"},
]

if htmloutdir
  Dir.mkdir(htmloutdir) unless Dir.exists?(htmloutdir)
end

errors = []
availables = shops.map do |s|
  begin
    if htmloutdir
      fname = File.join(htmloutdir, "#{s[:crawler].class.name.downcase}-#{Time.now.strftime("%Y%m%d-%H%M%S")}.html")
      fp = File.open(fname, "w")
    end
    r = s[:crawler].check(fp)
    if htmloutdir
      fp.close
      system("gzip #{fname}")
    end
    r ? {detail: r, name: s[:name]} : nil
  rescue => ex
    errors << {name: s[:name], ex: ex}
    nil
  end
end.compact

#errors.delete_if do |h|
#  h[:name] == "Amazon" &&
#  h[:ex].class == OpenURI::HTTPError &&
#  h[:ex].to_s == "503 Service Unavailable"
#end

exf = exfile ? File.open(exfile, "a") : STDERR
errors.each do |h|
  name = h[:name]
  ex = h[:ex]
  exf.puts Time.now.to_s
  exf.puts name
  exf.puts ex
  exf.puts ex.backtrace
  exf.puts ""
end
exf.close

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
