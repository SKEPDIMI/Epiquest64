module City_model
  def enter
    timeOfDay = @controller.timeOfDay
    puts "You arrive at the city entrance"
    
    response = @controller.at('console').prompt('What do you do now?', ['Leave to the beach', 'Go to the market', 'Explore'])
    if response == 1
      return '_BEACH'
    elsif response == 2
      return '_CITY_MARKET'
    elsif response == 3
      return '_CITY_EXPLORE'
    end

    return '_FINISH'
  end

  def id
    return '_CITY'
  end
end

module CityMarket_model
  def enter
    timeOfDay = @controller.timeOfDay
    puts 'We arrive to the market.'

    if timeOfDay.include? 'night'
      puts "NOTICE: Market is close during the night"
      response = @controller.at('console').prompt("What do you do now?", ["Head back to city entrance"])
      return '_CITY'
    else
      puts "The city market, packed as always."
      response = @controller.at('console').prompt("What do you do now?", ["Visit fishing shop", "Leave back to city entrance"])
      if response == 1
        return '_CITY_MARKET_FISH_SHOP'
      elsif response == 2
        return '_CITY'
      end
    end
  end

  def id
    return '_CITY_MARKET'
  end
end

module CityMarketFishing_model
  def enter
    puts "You enter the fish market"
    response = @controller.at('console').prompt("Where would you like to go?", [
      "Snapper's fish shop",
      "Barnum's fishing equipment"
    ]);

    if response == 1
      return '_CITY_MARKET_FISH_SHOP'
    elsif response == 2
      return '_CITY_MARKET_FISH_EQUIPMENT'
    end
  end

  def id
    return '_CITY_MARKET_FISH'
  end
end

module CityMarketFishingShop_model
  def enter
    # @npc_snapper = npcs.human['SNAPPER'].new @controller
    puts "You enter Snapper's fishing store"
    
    # @npc_snapper.dialogue
    
    response = @controller.at('console').prompt('What would you like to do?', [
      'Sell fish',
      'Buy fish'
    ]);

    if response == 1 # We want to sell to Snapper
      sell = true
      while sell == true
        @controller.at('console').clearScreen()
        # @npc_snapper.sell
        response = @controller.at('console').prompt('Sell again?', ['Yes', 'No'])
        if response == 2
          sell = false
          # @npc_snapper.goodbye
        end
      end
    elsif response == 2 # We want to buy from Snapper
      buy = true
      while buy == true
        @controller.at('console').clearScreen()
        # @npc_snapper.buy
        response = @controller.at('console').prompt('Buy again?', ['Yes', 'No'])
        if response == 2
          buy = false
          # @npc_snapper.goodbye
        end
      end
    end

    response = @controller.at('console').prompt('What would you like to do now?', [
      'Stay in store',
      'Back to fish market'
    ]);

    if response == 1
      return '_CITY_MARKET_FISH_SHOP'
    elsif response == 2
      return '_CITY_MARKET_FISH'
    end
  end
  def id
    return '_CITY_MARKET_FISH_SHOP'
  end
end