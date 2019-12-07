require 'curb'
require 'nokogiri'
require 'csv'
  link = ARGV[0].to_str
  file_name = ARGV[1].to_str
  unparsed_page = Curl.get(link) do |unparsed_page|
    unparsed_page.headers['User-Agent'] =  "Mozilla/4.0 (compatible; MSIE5.01; Windows NT)"
  end
  parsed_page = Nokogiri::HTML(unparsed_page.body_str)
  products = []
  products_count = parsed_page.at_xpath('//span[@class = "heading-counter"]').text.strip.split(' ')[0].to_f
  last_page = products_count / 25
  last_page = last_page.ceil
  for page in 1..last_page
    if page == 1
      pagination_url = link
    else
      pagination_url = link + "/?p=#{page}"
    end
    pagination_unparsed_page = Curl.get(pagination_url) do |pagination_unparsed_page|
      pagination_unparsed_page.headers['User-Agent'] =  "Mozilla/4.0 (compatible; MSIE5.01; Windows NT)"
    end
    pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page.body_str)
    puts "processing page #{page}"
    pagination_parsed_page.xpath('//h2[@class="nombre-producto-list prod-name-pack"]/a').each do |row|
      product_link = row.at_xpath('@href')
      unparsed_product_page = Curl.get(product_link) do |unparsed_product_page|
        unparsed_product_page.headers['User-Agent'] =  "Mozilla/4.0 (compatible; MSIE5.01; Windows NT)"
      end
      parsed_product_page = Nokogiri::HTML(unparsed_product_page.body_str)
      parsed_product_page.xpath('//ul[@class="attribute_radio_list"]/*' ).each do |row|
        tempName = row.at_xpath('//*[@id = "center_column"]/div/div/div[2]/div[2]/h1').text.strip
        tempVers = row.at_xpath('*/span[@class = "radio_label"]').text.strip
        tempPrice = row.at_xpath('*/span[@class = "price_comb"]').text.strip.split(' ')[0]
        tempImage = row.at_xpath('//*[@id = "bigpic"]').attribute('src').value
        products.push(
          name: tempName + "-" + tempVers,
          price: tempPrice,
          image: tempImage
        )
      end
    end
  end
  File.open(file_name, 'a') do |csv|
    products.each do |item|
      csv << "#{item[:name]};#{item[:price]};#{item[:image]}\n"
    end
  end
  puts "done."
