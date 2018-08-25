require_relative 'rod'

class User
  def initialize(controller, name = 'adventurer')
    @name = name
    @money = 0
    @fishingRod = FishingRod.new(controller)
    @inventory = [ # FOR TESTING ONLY. THIS SHOULD BE EMPTY
      {'_id' => "a8"},
      {'_id' => "a5"}
    ]
    @xp = 0
    @level = 0
  end

  def name
    @name.capitalize
  end

  attr_accessor :name, :money, :fishingRod, :xp, :level, :inventory
end