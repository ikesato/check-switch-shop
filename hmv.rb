# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Hmv
  URL = "http://www.hmv.co.jp/fl/2/324/1/"
  def check(htmlfp=nil)
    charset = nil
    html = open(URL) do |f|
      charset = f.charset
      f.read
    end
    htmlfp.write(html) if htmlfp
    doc = Nokogiri::HTML.parse(html, nil, charset)

    items = doc.css("ul.resultTileList > li").map do |d|
      category = d.css("h3 ~ p a").text
      next nil if category !~ /Game Hard/
      name = d.css("h3 a").text.strip
      price = d.css("div.itemStates div").first.text.gsub(/価格|\(税込\)|：/,"").strip
      pn = price.gsub(/[￥,]/, "").strip.to_i
      next nil if pn < 29000  #税抜きより低かったら違う商品
      next nil if pn >= 34000 #この値段より高いなら転売屋か Splatool2 セット
      available = (d.css("div span").text !~ /販売終了/)
      if name.empty? || price.empty? || !available
        nil
      else
        {name: name, price: price, available: available}
      end
    end.compact

    return nil if items.empty?
    result = [URL]
    result + items.map do |t|
      t[:name] + "\n" + t[:price] + "\n"
    end
  end
end
