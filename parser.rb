require 'nokogiri'
require 'open-uri'
require 'net/http'
require_relative 'advertisement'
require 'csv'


class Parser
  def self.get_advertisements(out_file)
    page_number = 1
    get_content = true
    start_time = Time.now
    while get_content
      puts "Page number: #{page_number}"
      csv = CSV.read(out_file, :headers=>true)
      existing_ads = csv['ID']
      advertisements = []
      link = if page_number == 1
               'https://cars.av.by/search?sort=price&order=asc'
             else
               "https://cars.av.by/search/page/#{page_number}?sort=price&order=asc"
             end
      request = URI(link)
      page = Nokogiri::HTML(open(request))
      get_content = false if page.xpath('//div[@class="listing-item-title"]').count < 25
      page.xpath('//div[@class="listing-item-title"]').each do |element|
        id = URI.parse(element.css('a').attribute('href').value).path.split('/').last
        if !existing_ads.include?(id)
          advertisements << Advertisement.new(element.css('a').attribute('href').value, id)
        else
          puts "#{id} is already in CSV"
        end
      end
      page_number += 1
      export_to_csv(advertisements, out_file)
      end_time = Time.now
      puts(convert_time(start_time, end_time))
    end
  end

  def self.export_to_csv(advertisements, file)
    puts 'Output to file'
    CSV.open(file, 'a') do |csv|
      # csv << ['ID', 'Make', 'Model', 'Price', 'Year', 'Odometer', 'Fuel type', 'Engine type', 'Color', 'Body',
      #         'Transmission', 'Drive']
      advertisements.each do |ad|
        csv << [ad.id, ad.make, ad.model, ad.price, ad.year, ad.odometer, ad.fuel_type, ad.engine_type, ad.color, ad.body, ad.transmission, ad.drive]
      end
    end
  end

  def self.convert_time(start_time, end_time)
    difference = end_time - start_time
    seconds    =  difference % 60
    difference = (difference - seconds) / 60
    minutes    =  difference % 60
    difference = (difference - minutes) / 60
    hours      =  difference % 24
    "Parsed page time: #{hours.to_i}:#{minutes.to_i}:#{seconds.to_i}"
  end
end

start_time = Time.now
puts "Start time: #{start_time}"
advertisements = Parser.get_advertisements('out.csv')
# Parser.export_to_csv(advertisements, 'out.csv')
end_time = Time.now
puts end_time
puts(Parser.convert_time(start_time, end_time))
