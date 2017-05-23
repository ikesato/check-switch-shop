# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Edion
  URL = "https://www.edion.com/item_list.html?keyword=Nintendo+Switch"
  def check(htmlfp=nil)
    charset = nil
    html = open(URL) do |f|
      charset = f.charset
      f.read
    end
    htmlfp.write(html) if htmlfp
    doc = Nokogiri::HTML.parse(html, nil, charset)

    items = doc.css("#resultBox>ul>li").map do |d|
      name = d.css(".item a").text.strip
      price = d.css(".price2").text.strip
      pn = price.gsub(/(￥|,|\(税込\))/,"").strip.to_i
      next nil if pn < 29000  #税抜きより低かったら違う商品
      next nil if pn >= 34000 #この値段より高いなら転売屋か Splatool2 セット
      available = (d.css(".icon2 li").text !~ /売り切れ/)
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
