# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Amiami
  URLS = ["http://www.amiami.jp/top/detail/detail?gcode=GAME-0017669", # neon+zelda
          "http://www.amiami.jp/top/detail/detail?gcode=GAME-0017666", # gray+zelda
          "http://www.amiami.jp/top/detail/detail?gcode=GAME-0017599", # neon
          "http://www.amiami.jp/top/detail/detail?gcode=GAME-0017598", # gray
         ]
  def check
    items = URLS.map do |url|
      check_one(url)
    end.compact

    return nil if items.empty?
    items.map do |t|
      t[:url] + "\n" + t[:name] + "\n" + t[:price] + "\n"
    end
  end

  def check_one(url)
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    name = doc.css("h2.heading_10").text.strip
    return nil if name =~ /在庫切れ/
    price = doc.css(".selling_price").text.strip
    available = (doc.css("#right_menu img[alt='販売停止中']").count != 1)
    if name.empty? || price.empty? || !available
      nil
    else
      {name: name, price: price, available: available, url: url}
    end

  end
end
