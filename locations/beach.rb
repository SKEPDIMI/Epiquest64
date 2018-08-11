module Beach_model
  def enter
    puts "You arrive at the beach"
    response = @console.prompt("What do you do?", ["Fish", "Head to docks", "Go to city"]);

    if response == 1
      return "_BEACH_FISH"
    elsif response == 2
      return "_BEACH_DOCKS"
    elsif response == 3
      return "_CITY"
    end
  end
  def id
    return '_BEACH'
  end
end

module BeachFish_model
  def enter
    puts "You sit by the hedge of a small rock cliff by the water"
    user = @controller.get('user')
    fishing_rod = user.fishing_rod

    if fishing_rod.health <= 0
      puts "You swing your fishing rod out into the water only to have it snap in half"
    else
      @console.clearScreen()
      puts "You begin fishing"

      result = fishing_rod.launch()
      
      @console.clearScreen()

      if !result
        @console.prompt "Tough luck.. You didnt catch anything!"
      elsif result
        @console.prompt "You caught a #{result['name']}! #{result['description']}"
        response = @console.prompt("Keep item?", ["Yes", "No"])
        if response == 1
          @controller.addToInventory(result)
          puts "Added #{result['name']} to inventory!"
        end
      end
      response = @console.prompt("What do you do now?", ["Fish again", "Back to beach"])

      if response == 1
        return '_BEACH_FISH'
      elsif response == 2
        return '_BEACH'
      end
    end
  end
  def id
    return '_BEACH_FISH'
  end
end