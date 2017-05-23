# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Toysrus
  URL = "https://www.toysrus.co.jp/c001060015010/"
  def check(htmlfp=nil)
    charset = nil
    html = open(URL) do |f|
      charset = f.charset
      f.read
    end
    htmlfp.write(html) if htmlfp
    doc = Nokogiri::HTML.parse(html, nil, charset)

    items = doc.css(".sub-category-items").map do |d|
      name = d.css("h2").text
      price = d.css("p.value .inTax").text
      available = (d.css(".out-of-stock").text !~ /在庫なし/)
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
