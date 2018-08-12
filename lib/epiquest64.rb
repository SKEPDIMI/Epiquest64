require 'whirly'

require_relative 'epiquest64/engine'
require_relative 'epiquest64/controller'

class Game_Engine
  include Engine
end
class Game_Controller
  include Controller
end

# Will create a controller
# Controllers get/set the game_data for all Modules
# It is sort of like a centralized store

controller = Game_Controller.new({
  'user' => nil,
  'time' => 7,
  'day' => 0
});

engine = Game_Engine.new(controller)

engine.play()