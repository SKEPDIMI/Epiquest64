require './lib/epiquest64.rb'

# Will create a controller
# Controllers get/set the game_data for all Modules
# It is sort of like a centralized store

controller = Controller.new({
  'user' => nil,
  'time' => 7,
  'day' => 0
});

engine = Engine.new(controller);

engine.play