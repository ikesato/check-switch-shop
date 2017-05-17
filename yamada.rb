# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Yamada
  URL = "http://www.yamada-denkiweb.com/category/108/001/009/"
  def check
    charset = nil
    html = open(URL) do |f|
      charset = "UTF-8"
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    items = doc.css(".item-wrapper").map do |d|
      name = d.css(".item-name").text.strip
      price = d.css(".item-price-box p.subject-text:nth-of-type(1) span.highlight").text.strip
      available = (d.css(".note").text !~ /好評につき売り切れました/)
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
