require_relative '../util/func'

class Console
  def initialize(controller)
    @func = Func.new
    @controller = controller
    @start_time = false
  end

  def finish_time
    @controller.add_time(Time.now - @start_time)
    @start_time = false
  end

  def log(message)
    puts("log >> #{message.upcase}")
  end


  def run(command)
    command = command.split " "
    case command[0]
    when "#time"
      display "Time is #{@controller.time_of_day} (#{@controller.getData('time')} on day #{@controller.getData('day')})"
    when "#set_time"
      if command[1] == ''
        display "No argument provided"
      else
        time = command[1].to_i
        if time > 24 || time < 0
          display "Time must be between 0 and 24"
        else
          @controller.set('time', time)
          display "Set time to #{time}"
        end
      end
    when "#get"
      user = @controller.getData('user')
      if user == nil
        display "No user has been initialized"
      else
        display """
        NAME: #{user.name}
        MONEY: #{@func.to_readable_money(user.money)}
        FISHING_ROD_HEALTH: #{user.fishingRod.health}
        XP: #{user.xp}
        LEVEL: #{user.level}
        """
      end
    when "#inventory"
      show_inventory()
    when "#gen_luck"
      x = @func.generate_luck
      puts x
    when "#exit"
      exit 0
    else
      display "Unknown command: #{command[0]}"
    end
  end

  def get_input() # Gets input from the user, or checks and runs commands
    # Please dont use get_input()/prompt() inside get_input :)
    @start_time = Time.now

    print "\nresponse > "

    response = $stdin.gets.chomp.downcase
    run response if is_сommand? response

    finish_time()
    return response
  end

  def is_сommand?(text)
    text.match /^#/
  end

  def clearScreen
    puts %x{clear}
  end

  def print_format(message, format = false)
    case true
    when format == false
      puts message
    when format == 'red'
      puts "\e[31m#{message}\e[0m"
    when format == 'italic'
      puts "\e[3m#{message}\e[23m"
    when format == 'underline'
      puts "\e[4m#{message}\e[24m"
    end
  end

  def display(message)
    print_format("\n# #{message}\n", 'red')
    $stdin.gets.chomp
  end

  def prompt(message, options = false, format = false)
    if options # Make sure the user's option is valid
      while true
        clearScreen()
        print_format("\n# #{message}\n", 'red')
        options.each do |option| # timeall of the options for the user
          puts "* #{option}"
        end
        response = get_input()

        if response.gsub(/\s+/, "") == ""
          display "> Empty response"
          next
        end

        options.each_with_index do |option, i|
          if option.downcase.include? response
            return i+1 # Return the index+1 of the selected option
          end
        end
      end

      # The response is invalid
      clearScreen()
      print_format("I'm not sure what that means", 'italic')
      prompt(message, options)
    else
      while true
        clearScreen()
        print_format("\n# #{message}\n", 'red')
        response = get_input()

        if response.gsub(/\s+/, "") == ""
          display "> Empty response"
          next
        end

        return response
      end
    end
  end

  def dialogue(name, message)
    puts "@#{name}: \"#{message}\""
  end

  def show_inventory
    user = @controller.getData('user')
    if user == nil
      log "No user has been initialized"
    else
      user = @controller.getData('user')
      inventory = @controller.get_inventory_populated
      if inventory.length == 0
        puts "*-= INVENTORY IS EMPTY 0/50 =-*"
        return false
      else
        display_text = "*-= INVENTORY #{inventory.length}/50 =-*\n"
        inventory.each_with_index do |item, i|
          price = @func.to_readable_money(item['price'])
          display_text += "|#{i + 1}| [#{item['name']}] | \"#{item['description']} \" | price: #{price} |\n"
        end
        display(display_text)
        return inventory
      end
    end
  end
  def getFromInventory
    while true
      inventory = show_inventory()
      if !inventory
        display "NO ITEMS TO SELECT"
        return false
      else
        puts "-- SELECT AN ITEM --"
        puts "-- DO !cancel TO EXIT --"
        response = get_input()
        if response == "!cancel"
          return false
        end
        response = response.to_i
        chosen = inventory[response-1]
        if response === 0 || !chosen
          display "Item at this index does not exist"
        else
          clearScreen()
          response = prompt("Chose #{chosen['name']}. Continue?", ["Yes", "No"]);

          if response == 1
            return chosen
          end
        end
      end
    end
  end
  def deleteFromInventory
    while true
      inventory = show_inventory()
      if !inventory
        display "NO ITEMS TO SELECT"
        return false
      else
        puts "-- DELETE AN ITEM --"
        puts "-- DO !cancel TO EXIT --"
        response = get_input()
        if response == "!cancel"
          return false
        end
        response = response.to_i
        chosen = inventory[response-1]
        if response === 0 || !chosen
          display("Item at this index does not exist")
        else
          clearScreen()
          response = prompt("Chose #{chosen['name']}. Continue?", ["Yes", "No"]);

          if response == 1
            @controller.deleteOneFromInventory(chosen)
            return true
          end
        end
      end
    end
  end
end
