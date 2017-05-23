# coding: utf-8
require 'open-uri'
require 'nokogiri'

class Omni7
  URL = "http://7net.omni7.jp/general/010007/170121switch"
  def check(htmlfp=nil)
    charset = nil
    html = open(URL) do |f|
      charset = f.charset
      f.read
    end
    htmlfp.write(html) if htmlfp
    doc = Nokogiri::HTML.parse(html, nil, charset)

    products = doc.css("div.spe-txtBox").map do |d|
      b = doc.css(d.css_path + " ~ div.spe-btn button.linkBtn").first
      available = (b.text != "SOLD OUT")
      name = d.css(".txtL").text
      price = d.css(".txtM").text
      if name.empty? || price.empty? || b.nil?
        nil
      else
        {name: name, price: price, available: available}
      end
    end

    targets = products.compact.delete_if do |pr|
      pr[:name] !~ /Nintendo Switch/ || !pr[:available]
    end

    return nil if targets.empty?
    result = [URL]
    result + targets.map do |t|
      t[:name] + "\n" + t[:price] + "\n"
    end
  end
end
