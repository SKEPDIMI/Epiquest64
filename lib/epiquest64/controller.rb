require_relative 'util/dataController'

class Controller
  def initialize(game_data)
    @game_data = game_data
    @data_controller = DataController.new
    @connected = {}
  end
  def connect(agent, name)
    @connected[name] = agent
  end
  def at(name)
    return @connected[name]
  end
  def getData(prop)
    return @game_data[prop]
  end
  def setData(prop, value)
    @game_data[prop] = value
    if prop == 'user'
      at('console').update_stats
    end
  end
  def add_time(seconds = 0) # Changes from real life seconds to game hours / days
    # 8.64 seconds in a day
    # 1 second in game time is 0.0001
    # 1 real second is 70% times faster in game

    secondsInDay = 86400
    gameTimeFactor = 0.00017 #0.0001 (1 game sec) * 1.7 (70%)
    secondsInGameDay = secondsInDay * gameTimeFactor

    gameSeconds = (seconds * gameTimeFactor) # Game seconds are %70 faster
    # daysPassed = (gameSeconds * secondsInGameDay).floor

    @game_data['time'] += gameSeconds % secondsInGameDay
    @game_data['days'] = (@game_data['time'] / 24).floor
  end
  def time_of_day
    time = @game_data['time']
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
  def addToInventory(_id)
    item = @data_controller.findById(_id)

    if (item['type'] === '_money')
      @game_data['user'].money += item.price
    else
      inventory = @game_data['user'].inventory
      if inventory.length < 50
        @game_data['user'].inventory << {'_ref' => item['_ref'], '_id' => item['_id']}
      else
        response = @connected['console'].prompt("YOUR INVENTORY IS FULL! Would you like to make space or discard item?", [
          'Make space',
          'Discard item'
        ])
        if response == 1
          deleted = @connected['console'].deleteFromInventory

          if deleted
            @game_data['user'].inventory << {'_ref' => item['_ref'], '_id' => item['_id']}
            @connected['console'].display("Saved item in inventory!")
          end
        end
      end
    end
  end
  def get_inventory_populated
    inventory = (@game_data['user'].inventory).dup

    return @data_controller.populate(inventory)
  end
  def addMoney(m)
    @game_data['user'].money += m
    at('console').update_stats
  end
  def deleteOneFromInventory(item)
    _inventory = @game_data['user'].inventory

    _inventory.each_with_index do |x, i|
      if x['_id'] === item['_id']
        _inventory.delete_at(i)
        break
      end
    end
  end
  def dataFindOne(q = {}, ref = false)
    return @data_controller.findOne(q, ref)
  end
  def dataFindById(id, ref = false)
    return @data_controller.findById(id, ref)
  end
  def dataFind(q = {}, ref = false)
    return @data_controller.find(q, ref)
  end
end
