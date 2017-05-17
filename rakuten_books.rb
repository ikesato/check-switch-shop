# coding: utf-8
require 'open-uri'
require 'nokogiri'

class RakutenBooks
  URL = "http://books.rakuten.co.jp/search/nm?cy=0&e=0&h=30&mt=0&o=0&f=A&s=1&g=006514001&spv=2&sitem=Nintendo+Switch+Joy-Con&v=2&sv=30&user_id=&scid=af_pc_etc&sc2id=353001532"
  def check
    charset = nil
    html = open(URL) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    items = doc.css(".rbcomp__item-list__item").map do |d|
      name = d.css(".rbcomp__item-list__item__title").text.strip
      price = d.css(".rbcomp__item-list__item__price").text.strip
      pn = price.gsub(/[,円]/,"").strip.to_i
      next nil if pn < 29000  #税抜きより低かったら違う商品
      next nil if pn >= 34000 #この値段より高いなら転売屋
      available = (d.css(".rbcomp__item-list__item__stock").text !~ /ご注文できない商品/)
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
