require 'json'
require_relative '../util/func'

class Func
  include Func_model
end

module FishingRod_model
  def initialize
    @func = Func.new
    @health = 10
    @power = 5
    @bait = nil
    
    fish_data = File.read(__dir__ + '/../data/fish.json')
    @fish_record = JSON.parse(fish_data)
  end

  def launch(time)
    if @health <= 0
      puts "Your rod is broken"
      return nil
    end

    # Here we look for a random fish
    # Fish have a rarity level from -1 to 5
    # They also have requirment like time or power

    x = @func.generate_luck()
    
    available = @fish_record.delete_if { |key, value| value['rarity'] > x } # Only fish with a rarity less / equal to our luck

    choices = available.delete_if do |key, value| # Will filter out our choice based off requirments
      requirements = value['requirment']

      if requirements # If fish has requirments to catch
        puts "#{value['name']} has requirment"
        if requirment['time'] # If time is a requirment
          if !requirements['time'].include?(time) # If we dont have this requirment, delete fish
            return true
          end
        end
        if requirements['power'] # If power is a requirment
          if value['power'] > @power
            return true
          end # If we dont have enough power, delete fish
        end
      end
    end

    values = choices.values
    selected = values[rand(values.size)]
    
    return selected
  end

  attr_reader :health
end