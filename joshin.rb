# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Joshin
  URL = "http://joshinweb.jp/game/40519.html"
  def check
    charset = nil
    html = open(URL) do |f|
      charset = "Shift_JIS"
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    items = doc.css("table").map do |d|
      next nil if d.css("table table img[alt='さらに詳しく!']").count != 1
      name = d.css("td")[2].text
      price = d.css("span.fsL").first.text
      available = (d.css("span.fsL").last.text != "販売休止中です")
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
