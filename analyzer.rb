require_relative 'parsed_advertisement'
require 'csv'
require 'pry'

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
puts "Most High odometer: #{Analyzer.most_high_odometer(parsed_advertisements).odometer} km \n\n"
puts "Average odometer: #{Analyzer.average_odometer(parsed_advertisements).to_i} km \n\n"
p "Production year distribution: #{Analyzer.distribution(parsed_advertisements, 'year')}"
puts "\n\n"
p "Transmissions distribution: #{Analyzer.distribution(parsed_advertisements, 'transmission')}"
puts "\n\n"
p "Body distribution: #{Analyzer.distribution(parsed_advertisements, 'body')}"
puts "\n\n"
p "Color distribution: #{Analyzer.distribution(parsed_advertisements, 'color')}"
puts "\n\n"
p "Drive distribution: #{Analyzer.distribution(parsed_advertisements, 'drive')}"
puts "\n\n"
p "Fuel type distribution: #{Analyzer.distribution(parsed_advertisements, 'fuel_type')}"
puts "\n\n"
p "Make distribution: #{Analyzer.distribution(parsed_advertisements, 'make')}"
puts "\n\n"
