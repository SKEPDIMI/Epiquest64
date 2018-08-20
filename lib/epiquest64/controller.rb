require_relative 'util/dataController'

class DataController
  include DataControllerModel
end

module Controller
  def initialize(gameData)
    @gameData = gameData
    @dataController = DataController.new
    @connected = {}
  end
  def connect(agent, name)
    @connected[name] = agent
  end
  def at(name)
    return @connected[name]
  end
  def getData(prop)
    return @gameData[prop]
  end
  def setData(prop, value)
    @gameData[prop] = value
  end
  def addTime(seconds = 0) # Changes from real life seconds to game hours / days
    # 8.64 seconds in a day
    # 1 second in game time is 0.0001
    # 1 real second is 70% times faster in game

    secondsInDay = 86400
    gameTimeFactor = 0.00017 #0.0001 (1 game sec) * 1.7 (70%)
    secondsInGameDay = secondsInDay * gameTimeFactor

    gameSeconds = (seconds * gameTimeFactor) # Game seconds are %70 faster
    # daysPassed = (gameSeconds * secondsInGameDay).floor

    @gameData['time'] += gameSeconds % secondsInGameDay
    @gameData['days'] = (@gameData['time'] / 24).floor
  end
  def timeOfDay
    time = @gameData['time']
    case
    when time >= 23 && time <= 1 # 10PM - 1AM
      return 'midnight'
    when time >= 1 && time <= 11 # 1AM - 11AM
      return 'morning'
    when time >= 11 && time <= 13 # 11AM - 1PM
      return 'midday'
    when time >= 13 && time <= 18 # 1PM - 6PM
      return 'afternoon'
    when time >= 18 && time <= 23 # 6PM - 10PM
      return 'night'
    end
  end
  def addToInventory(item)
    if (item['type'] === '_money')
      @gameData['user'].money += item.price
    else
      inventory = @gameData['user'].inventory
      if inventory.length < 50
        @gameData['user'].inventory << {'_ref' => item['_ref'], '_id' => item['_id']}
      else
        response = @connected['console'].prompt("YOUR INVENTORY IS FULL! Would you like to make space or discard item?", [
          'Yes',
          'No'
        ])
        if response == 1
          deleted = @connected['console'].deleteFromInventory

          if deleted
            @gameData['user'].inventory << {'_ref' => item['_ref'], '_id' => item['_id']}
            @connected['console'].display("Saved item in inventory!")
          end
        end
      end
    end
  end
  def getInventoryPopulated
    u_inventory = (@gameData['user'].inventory).dup
    i_inventory = @dataController.populate(u_inventory) # populated inventory

    return i_inventory
  end
  def addMoney(m)
    @gameData['user'].money += m
  end
  def deleteOneFromInventory(item)
    _inventory = @gameData['user'].inventory

    _inventory.each_with_index do |x, i|
      if x['_id'] === item['_id']
        _inventory.delete_at(i)
        break
      end
    end
  end
  def dataFindOne(collection, q = {})
    return @dataController.findOne(collection, q)
  end
  def dataFindById(collection, id)
    return @dataController.findById(collection, id)
  end
  def dataFind(collection, q = {})
    return @dataController.find(collection, q)
  end
end