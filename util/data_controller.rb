require 'json'

module DataController_model
  def initialize
    data = File.read(__dir__ + '/../data/data.json')
    @data = JSON.parse(data)
  end

  def findById(id)
    @data.each do |key, value|
      if key === id
        value['_id'] = id
        return value
      end
    end

    return {}
  end

  def findOne(q)
    @data.each do |id, data|
      match = false
      q.keys.each do |key| # For each key in query
        if data[key] == q[key] # If the query[key] is == to the data[key]
          match = true
        else
          match = false
          break
        end
      end
      if match
        data['_id'] = id
        return data
      end
    end

    return {}
  end

  def find(q)
    results = {}

    @data.each do |id, data|
      match = false
      q.keys.each do |key| # For each key in query
        if data[key] == q[key] # If the query[key] is == to the data[key]
          match = true
        else
          match = false
          break
        end
      end
      if match
        data['_id'] = id
        results[id] = data
      end
    end

    return results
  end

  def populate(array)
    populated_array = []
    array.each do |id|
      # find id that matches in @data and add it to p_array
      populated_array << findById(id)
    end

    return populated_array
  end
end