require_relative 'parsed_advertisement'
require 'csv'
require 'pry'
require 'prawn'
require 'squid'

class Analyzer
  def self.import_from_csv(file)
    CSV.read(file).drop(1).map do |ad|
      ParsedAdvertisement.new(make: ad[1],
                              model: ad[2],
                              price: ad[3],
                              year: ad[4],
                              odometer: ad[5],
                              fuel_type: ad[6],
                              engine_type: ad[7],
                              color: ad[8],
                              body: ad[9],
                              transmission: ad[10],
                              drive: ad[11])
    end
  end

  def self.most_high_odometer(ads)
    ads.max_by(&:odometer)
  end

  def self.average_odometer(ads)
    ads.map do |ad|
      ad.odometer.to_i
    end.inject { |sum, el| sum + el }.to_f / ads.size
  end

  def self.average_year(ads)
    ads.map do |ad|
      ad.year.to_i
    end.inject { |sum, el| sum + el }.to_f / ads.size
  end

  def self.max_price(ads)
    ads.max_by(&:price)
  end

  def self.distribution(ads, type)
    Hash[ads.group_by { |ad| ad.instance_variable_get("@#{type}") }.reject { |k,v| k.nil? }.sort.to_h.map { |k, v| [k, v.count] }]
  end
end

parsed_advertisements = Analyzer.import_from_csv('out.csv')

transmissions_data = { "Transmissions distribution": Analyzer.distribution(parsed_advertisements, 'transmission') }
body_data = { "Body distribution": Analyzer.distribution(parsed_advertisements, 'body') }
color_data = { "Color distribution": Analyzer.distribution(parsed_advertisements, 'color') }
drive_data = { "Drive distribution": Analyzer.distribution(parsed_advertisements, 'drive') }
fuel_data = { "Fuel type distribution": Analyzer.distribution(parsed_advertisements, 'fuel_type')}
# make_data = { "Make distribution": Analyzer.distribution(parsed_advertisements, 'make') }
# years_data = { "Production year distribution": Analyzer.distribution(parsed_advertisements, 'year') }

Prawn::Document.generate('analyze.pdf') do
  font_families.update(
    'Roboto' => { bold: 'Roboto-Bold.ttf',
                  italic: 'Roboto-Italic.ttf',
                  bold_italic: 'Roboto-BoldItalic.ttf',
                  normal: 'Roboto-Medium.ttf' })
  text "Most High odometer: #{Analyzer.most_high_odometer(parsed_advertisements).odometer} km \n\n"
  text "Average odometer: #{Analyzer.average_odometer(parsed_advertisements).to_i} km \n\n"
  font('Roboto') do
    chart transmissions_data, labels: [true], steps: 10
    move_down 50
    chart fuel_data, labels: [true], steps: 10
    start_new_page
    chart color_data, labels: [true], steps: 15
    move_down 50
    chart drive_data, labels: [true], steps: 10
    start_new_page
    chart body_data, labels: [true, true], steps: 10, every: 2
  end
end
