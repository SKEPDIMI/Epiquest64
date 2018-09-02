require 'json'

class DataController
  def initialize
    @data = {} # This should not be changed after it has been initialized
    Dir[__dir__ + '/../../../data/*.json'].each do |filepath| # Turns @data into hash of collections based off the data directory
      filename = File.basename(filepath, ".json")
      file = open(filepath)
      @data[filename] = JSON.parse(file.read)
      @data[filename].freeze() # is immutable
      # @data = {
      #   'fishing_loot': [
      #      {}
      #      {}
      #      {}
      #    ],
      #   'weapons': [
      #      {}
      #      {}
      #      {}
      #    ]
      # }
    end
  end

  def findById(_id, ref = false)
    collection = get_collection(ref)

    collection.each do |item|
      if item['_id'] === _id
        return item
      end
    end

    return {}
  end

  def findOne(q = {}, ref = false)
    collection = get_collection(ref)
    
    if q.blank? # There is no query, return all
      collection.each do |item|
        value['_ref'] = collection
      end
      return collection
    end

    collection.each do |item|
      match = false
      q.keys.each do |key| # For each key in query
        if item[key] == q[key] # If the query[key] is == to the data[key]
          match = true
        else
          match = false
          break
        end
      end
      if match
        item['_ref'] = collection
        return item
      end
    end

    return {}
  end

  def find(q = {}, ref = false)
    collection = get_collection(ref)

    if q.empty?
      collection.each do |item|
        item['_ref'] = ref
      end
      return collection
    end

    results = []

    collection.each do |item|
      match = false
      q.keys.each do |key| # For each key in query
        if item[key] == q[key] # If the query[key] is == to the item[key]
          match = true
        else
          match = false
          break
        end
      end
      if match
        item['_ref'] = collection
        results << item # results.a0 = { _id: a0, name: '' }
      end
    end

    return results
  end

  def populate(array)
    populated_array = []
    array.each do |item|
      # find _id that matches in @data and add it to pArray

      populated_item = findById(item['_id'], item['_ref'])
      populated_array << populated_item
    end

    return populated_array
  end

  private
    def get_collection(ref)
      if (!ref) # Search all of the collections
        # @data => { 'loot': [a, b], 'weapons': [c, d] }
        # @data.values => [ [a, b], [c, d] ]
        return @data.values.flatten # [ a, b, c, d ]
      else # Search in the collection provided
        return @data[ref]
      end
    end
end