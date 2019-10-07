require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'pry'

class Advertisement
  attr_accessor :link, :id
  attr_reader :make, :model, :price, :year, :odometer, :fuel_type, :engine_type, :color, :body, :transmission, :drive

  def initialize(link, id)
    @link = link
    @id = id
    content
    puts '============================================================='
    puts "#{@id} - #{@link} - #{@make} - #{@model} - #{@price} - #{@year} - #{@odometer} - #{@fuel_type} -
          #{@engine_type} - #{@color} - #{@body} - #{@transmission} - #{@drive}"
    puts '============================================================='
  end

  private

  def content
    request = URI(@link)
    page = Nokogiri::HTML(open(request))
    @make = page.css('a[@class="breadcrumb-link"]')[1].text.strip
    @model = page.css('a[@class="breadcrumb-link"]')[2].children.last.text.strip
    @price = page.css('span[@class="card-price-main-secondary"]').text.strip
    @year = page.at('div[@class="card-info"] ul li dt:contains("Год выпуска")').parent.at('dd').text
    @odometer = page.at('div[@class="card-info"] ul li dt:contains("Пробег")')&.parent&.at('dd')&.text&.slice!(/\d+/)
    @fuel_type = page.at('div[@class="card-info"] ul li dt:contains("Тип топлива")')&.parent&.at('dd')&.text
    @engine_type = page.at('div[@class="card-info"] ul li dt:contains("Объем")')&.parent&.at('dd')&.text&.slice!(/\d+/)
    @color = page.at('div[@class="card-info"] ul li dt:contains("Цвет")')&.parent&.at('dd')&.text
    @body = page.at('div[@class="card-info"] ul li dt:contains("Тип кузова")')&.parent&.at('dd')&.text
    @transmission = page.at('div[@class="card-info"] ul li dt:contains("Трансмиссия")')&.parent&.at('dd')&.text
    @drive = page.at('div[@class="card-info"] ul li dt:contains("Привод")')&.parent&.at('dd')&.text
  end
end
