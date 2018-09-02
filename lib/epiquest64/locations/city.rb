module CityModel
  def enter
    time_of_day = @controller.time_of_day
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

module CityMarketModel
  def enter
    time_of_day = @controller.time_of_day
    puts 'We arrive to the market.'

    if time_of_day.include? 'night'
      puts "NOTICE: Market is close during the night"
      response = @controller.at('console').prompt("What do you do now?", ["Head back to city entrance"])
      return '_CITY'
    else
      puts "The city market, packed as always."
      response = @controller.at('console').prompt("What do you do now?", [
        "Visit fish market",
        "Leave back to city entrance"
      ]);

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

module CityMarketFishingModel
  def enter
    puts "You enter the fish market"
    response = @controller.at('console').prompt("Where would you like to go?", [
      "Snapper's fish shop",
      "Barnum's fishing equipment",
      "Back to city entrance"
    ]);

    if response == 1
      return '_CITY_MARKET_FISH_SHOP'
    elsif response == 2
      return '_CITY_MARKET_FISH_EQUIPMENT'
    elsif response == 3
      return '_CITY'
    end
  end

  def id
    return '_CITY_MARKET_FISH'
  end
end

module CityMarketFishingShopModel
  def enter
    @npcSnapper = @controller.at('npcs').get('_SNAPPER');
    puts "You enter Snapper's fishing store"
    
    @npcSnapper.greet
    @npcSnapper.business

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