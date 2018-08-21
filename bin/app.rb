require './lib/epiquest64.rb'

# Will create a controller
# Controllers get/set the game_data for all Modules
# It is sort of like a centralized store

controller = GameController.new({
  'user' => nil,
  'time' => 7,
  'day' => 0
});

engine = GameEngine.new(controller);

engine.play