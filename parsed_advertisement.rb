require 'pry'

class ParsedAdvertisement
  attr_accessor :make, :model, :price, :year, :odometer, :fuel_type, :engine_type, :color, :body, :transmission, :drive

  def initialize(hash)
    hash.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end
end
