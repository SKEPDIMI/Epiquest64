require_relative 'rod'

class FishingRod
  include FishingRod_model
end

module User
  def initialize(controller, name = 'adventurer')
    @name = name
    @gold = 0
    @fishing_rod = FishingRod.new(controller)
    @inventory = []
    @experience = 0
    @level = 0
  end

  def name
    @name.capitalize
  end

  attr_accessor :name, :gold, :fishing_rod, :experience, :level, :inventory
end