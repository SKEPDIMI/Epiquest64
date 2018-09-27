class Snapper
  @@name = "Snapper the fish merchant"
  @@greetings = ['Get yer fish half the price when you']
  @@goodbyes = ["Goodbye!"]

  def initialize(controller)
    @controller = controller
  end
  def greet
    @controller.at('console').dialogue(@@name, @@greetings[rand(0..@@greetings.length-1)])
  end
  def goodbye
    @controller.at('console').dialogue(@@name, @@goodbyes[rand(0..@@greetings.length-1)])
  end
  def business
    response = @controller.at('console').prompt('What business do you seek today?', [
      'Sell fish',
      'Buy fish',
      'None'
    ]);

    if response == 1 # We want to sell to Snapper
      sell = true
      while sell == true
        @controller.at('console').clearScreen()
        items = @controller.at('console').getFromInventory()
        @controller.at('console').clearScreen()

        if items.empty?
          sell = false
          goodbye()
        else
          total_price = items.collect{|i| i['price']}.reduce(&:+)
          puts "Sold for #{total_price}"
          
          @controller.addMoney(total_price);

          items.each do |item|
            @controller.deleteOneFromInventory(item)
          end

          response = @controller.at('console').prompt('Sell again?', ['Yes', 'No'])
          if response == 2
            sell = false
            goodbye()
          end
        end
      end
    elsif response == 2 # We want to buy from Snapper
      buying = true
      while buying
        @controller.at('console').clearScreen()
        @controller.addToInventory('a1')
        @controller.at('console').display('Bought gold fish! Awesome!')
        response = @controller.at('console').prompt('Buy again?', ['Yes', 'No'])
        if response == 2
          buying = false
          goodbye
        end
      end
    elsif response == 3
      goodbye
    end
  end
end
