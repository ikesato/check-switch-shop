# coding: utf-8
require 'open-uri'
require 'nokogiri'

class ItoYokado
  URLS = ["http://iyec.omni7.jp/detail/4902370535709",
          "http://iyec.omni7.jp/detail/4902370535716"]
  def check(htmlfp=nil)
    items = URLS.map do |url|
      check_one(url, htmlfp)
    end.compact

    return nil if items.empty?
    items.map do |t|
      t[:url] + "\n" + t[:name] + "\n" + t[:price] + "\n"
    end
  end

  def check_one(url, htmlfp=nil)
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    if htmlfp
      htmlfp.puts("-----------------------------------------------------------------------")
      htmlfp.puts("URL => #{url}")
      htmlfp.write(html)
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    name = doc.css("h1").text.strip
    price = doc.css(".mod-productDetails3Column_productInfoListDetail .js-productInfoPriceStyle").text.strip
    available = (doc.css(".cartBtn input.linkBtn").attr("value").text !~ /在庫切れ/)
    if name.empty? || price.empty? || !available
      nil
    else
      {name: name, price: price, available: available, url: url}
    end

  end
end
