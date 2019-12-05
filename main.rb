require 'curb'
require 'nokogiri'

def scraper
  link = "https://www.petsonic.com/snacks-huesos-para-perros/"
  unparsed_page = Curl.get(link) do |unparsed_page|
    unparsed_page.headers['User-Agent'] =  "Mozilla/4.0 (compatible; MSIE5.01; Windows NT)"
  end

  parsed_page = Nokogiri::HTML(unparsed_page.body_str)
  names = []
  page = 1
  last_page = 4

  while page <= last_page
    if page == 1
      pagination_url = link
    else
      pagination_url = link + "/?p=#{page}"
    end
    pagination_unparsed_page = Curl.get(pagination_url) do |pagination_unparsed_page|
      pagination_unparsed_page.headers['User-Agent'] =  "Mozilla/4.0 (compatible; MSIE5.01; Windows NT)"
    end
    pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page.body_str)
    puts pagination_url
    pagination_parsed_page.xpath('//h2[@class="nombre-producto-list prod-name-pack"]/a').each do |row|

      product_link = row.at_xpath('@href')

      puts product_link
      unparsed_product_page = Curl.get(product_link) do |unparsed_product_page|
        unparsed_product_page.headers['User-Agent'] =  "Mozilla/4.0 (compatible; MSIE5.01; Windows NT)"
      end

      parsed_product_page = Nokogiri::HTML(unparsed_product_page.body_str)

      parsed_product_page.xpath('//ul[@class="attribute_radio_list"]/*' ).each do |row|

        tempName = row.at_xpath('//*[@id = "center_column"]/div/div/div[2]/div[2]/h1').text.strip
        tempVers = row.at_xpath('*/span[@class = "radio_label"]').text.strip
        tempPrice = row.at_xpath('*/span[@class = "price_comb"]').text.strip
        tempImage = row.at_xpath('//*[@id = "bigpic"]').attribute('src').value

        names.push(
          name: tempName + " " + tempVers,
          price: tempPrice,
          image: tempImage
        )

      end
    end
    page += 1
  end

  puts names
  puts "done."
end
scraper()
