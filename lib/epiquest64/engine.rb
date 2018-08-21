require_relative 'models/user'
require_relative 'agents/console'
require_relative 'agents/map'
require_relative 'agents/NPCs'

class Engine
  def initialize(controller)
    @controller = controller

    @controller.connect(Console.new(controller), 'console')
    @controller.connect(Map.new(controller), 'map')
    @controller.connect(NPCs.new(controller), 'npcs')

    # @npcs = NPCs.new(controller)
  end
  def play
    @controller.at('console').display """
       _____  _____   _____  _____  _   _  _____  _____  _____             ____    ___ 
      |  ___|| ___ \\|_   _||  _  || | | ||  ___|/  ___||_   _|           / ___|  /   |
      | |__  | |_/ /  | |  | | | || | | || |__  \\ `--.   | |    ______  / /___  / /| |
      |  __| |  __/   | |  | | | || | | ||  __|  `--. \\  | |   |______| | ___ \\/ /_| |
      | |___ | |     _| |_ \\ \\/' /| |_| || |___ /\\__/ /  | |            | \\_/ |\\___  |
      \\____/ \\_|     \\___/  \\_/\\_\\ \\___/ \\____/ \\____/   \\_/            \\_____/    |_/
      EPIQUEST 64
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      > Made by SKEPDIMI                           
      > Please play in fullscreen
      > To exit type \"\#exit\" in prompt
      > Begin: RETURN                                             
    """

    @controller.at('console').clearScreen()
    
    name = @controller.at('console').prompt("What is your name, traveller?").capitalize
    
    @controller.setData('user', User.new(@controller, name));
    user = @controller.getData('user');

    @controller.at('console').display("An honor to meet you, #{user.name}.\n# Let us begin our quest.\n> PRESS ENTER TO BEGIN");

    gameLoop()
  end

  def gameLoop
    current_location = @controller.at('map').locations(ARGV.first || '_START')
    last_scene = @controller.at('map').locations('_FINISH')

    # THIS IS THE MAIN GAME LOOP
    while current_location != last_scene
      @controller.at('console').clearScreen()
      next_location_id = current_location.enter() || '_FINISH' # Enter the current location, which will return the next scene's ID WHEN the player finishes the given scene
      current_location = @controller.at('map').locations(next_location_id) # Current location is now the location that goes after the completed location
    end

    current_location.enter()
  end
end
