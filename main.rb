require 'curb'
require 'nokogiri'
link = "https://www.petsonic.com/purina-pro-plan-snack-dentalife-mini-para-perros.html#/2359-unidades-4_unidades_x_345gr"
http = Curl.get(link) do |http|
  http.headers['User-Agent'] =  "Mozilla/4.0 (compatible; MSIE5.01; Windows NT)"
end

doc = Nokogiri::HTML(http.body_str)
names = []
doc.xpath('//ul[@class="attribute_radio_list"]/*' ).each do |row|

  tempName = row.at_xpath('//*[@id="center_column"]/div/div/div[2]/div[2]/h1').text.strip
  tempVers = row.at_xpath('*/span[@class = "radio_label"]').text.strip
  tempPrice = row.at_xpath('*/span[@class = "price_comb"]').text.strip
  tempImage = row.at_xpath('//*[@id="bigpic"]').attribute('src').value

  names.push(
    name: tempName + " " + tempVers,
    price: tempPrice,
    image: tempImage
  )

end

puts names
