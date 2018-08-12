module Snapper_model
  def initialize(controller)
    @@name = "Snapper the fish merchant"
    @@greetings = [
      'Get yer fish half the price when you'
    ]
    @@goodbyes = [
      "Goodbye!"
    ]
    @controller = controller
  end
  def greet
    @controller.at('console').dialogue(@@name, @@greetings[rand(0..@@greetings.length-1)])
  end
end
