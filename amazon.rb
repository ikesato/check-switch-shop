# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Amazon
  URL = "https://www.amazon.co.jp/b//ref=as_li_ss_tl?ie=UTF8&node=4731379051&linkCode=ll2&tag=vrinfo-22&linkId=ebf436d903ca774e58ecfd6f0bde9d94"
  def check(htmlfp=nil)
    charset = nil
    html = open(URL) do |f|
      charset = f.charset
      f.read
    end
    htmlfp.write(html) if htmlfp
    doc = Nokogiri::HTML.parse(html, nil, charset)

    items = doc.css(".s-result-item").map do |d|
      name = d.css("h2").text
      price = d.css(".s-price").text
      pn = price.gsub(/[￥,]/, "").strip.to_i
      next nil if pn < 29000  #税抜きより低かったら違う商品
      next nil if pn >= 34000 #この値段より高いなら転売屋
      if name.empty? || price.empty?
        nil
      else
        {name: name, price: price}
      end
    end.compact

    return nil if items.empty?
    result = [URL]
    result + items.map do |t|
      t[:name] + "\n" + t[:price] + "\n"
    end
  end
end
