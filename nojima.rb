# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Nojima
  URL = "https://online.nojima.co.jp/category/10006903/?searchCategoryCode=10006903&mode=image&pageSize=15&currentPage=1&alignmentSequence=1&searchDispFlg=true&attributeValue=0_5"
  def check(htmlfp=nil)
    charset = nil
    html = open(URL) do |f|
      charset = "UTF-8"
      f.read
    end
    htmlfp.write(html) if htmlfp
    doc = Nokogiri::HTML.parse(html, nil, charset)

    items = doc.css(".shouhinlist").map do |d|
      name = d.css(".cmdty_iteminfo div:nth-of-type(1) span:nth-of-type(3)").text.strip
      price = d.css(".cmdty_iteminfo .price").text.strip
      pn = price.gsub(/[,円]/,"").strip.to_i
      next nil if pn < 29000  #税抜きより低かったら違う商品
      next nil if pn >= 34000 #この値段より高いなら保証込みのいらないやつ
      available = (d.css("img[src='/contents/image/out100px.gif']").count == 0)
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
