# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Yodobashi
  URL = "http://www.yodobashi.com/?word=Nintendo+Switch+%E6%9C%AC%E4%BD%93"
  def check
    charset = nil
    html = open(URL) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    items = doc.css("div[data-salesinformationcode]").map do |d|
      name = d.css("div.pName").text.strip
      next nil if name !~ /Nintendo Switch本体/
      price = d.css("span.productPrice").text.strip
      pn = price.gsub(/[￥,]/,"").strip.to_i
      next nil if pn < 29000  #税抜きより低かったら違う商品
      next nil if pn >= 34000 #この値段より高いなら転売屋か Splatool2 セット
      available = (d.css("span.gray").text !~ /販売休止中です/)
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
