require 'ffi-ncurses'
require_relative '../util/func'
include FFI::NCurses

$USE_NCURSES = ARGV.delete('--use-ncurses')

def print_c(s)
  if $USE_NCURSES
    printw s + "\n"
    refresh
  else
    puts s
  end
end

def gets_c()
  if $USE_NCURSES
    # getstr don't work D:
    s = ''
    while true
      c = getch
      if c.chr == "\n" then break end
        s += c.chr
      end
      return s
  else
    $stdin.gets
  end
end

class Console
  def initialize(controller)
    if $USE_NCURSES
      initscr
      start_color
      init_pair 1, COLOR_RED, COLOR_BLACK
    end
    @func = Func.new
    @controller = controller
    @start_time = false
  end

  def finish_time
    @controller.add_time(Time.now - @start_time)
    @start_time = false
  end

  def log(message)
    print_c("log >> #{message.upcase}")
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
      print_c x
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
    response = gets_c.chomp.downcase
    if response[0] === '#' # This will detect commands from the user
      stripped = response.gsub(/\s+/, "")
      if (stripped === '#time')
        display "Time is #{@controller.time_of_day} (#{@controller.getData('time')} on day #{@controller.getData('day')})"
      elsif (stripped == "#get")
        # Find arguments and return data
        user = @controller.getData('user')
        if user == nil
          display "No user has been initialized"
        else
          display """
          NAME: #{user.name}
          MONEY: #{@func.toReadableMoney(user.money)}
          FISHING_ROD_HEALTH: #{user.fishingRod.health}
          XP: #{user.xp}
          LEVEL: #{user.level}
          """
        end
      elsif stripped[0..7] == '#settime'
        arg = stripped.gsub('#settime', '')
        if arg == ''
          display "No argument provided"
        else
          time = arg.to_i
          if time > 24 || time < 0
            display "Time must be between 0 and 24"
          else
            @controller.set('time', time)
            display "Set time to #{time}"
          end
        end
      elsif stripped == '#gen_luck'
        x = @func.generate_luck
        print_c x
      elsif stripped == '#exit'
        exit(0)
      elsif stripped == "#inventory"
        showInventory()
      else
        display "Unknown command: #{stripped}"
      end

      finish_time()
      return get_input()
    end

    finish_time()
    return response
  end

  def clearScreen
    if $USE_NCURSES
      clear
    else
      print_c %x{clear}
    end
  end

  def print_format(message, format = nil)
    if $USE_NCURSES
      case format
      when 'red'
        attron COLOR_PAIR(1)
        print_c message
        attroff COLOR_PAIR(1)
      when 'italic'
        attron A_ITALIC
        print_c message
        attroff A_ITALIC
      when 'underline'
        attron A_UNDERLINE
        print_c message
        attroff A_UNDERLINE
      else
        print_c message
      end
    else
      case format
      when 'red'
        print_c "\e[31m#{message}\e[0m"
      when 'italic'
        print_c "\e[3m#{message}\e[23m"
      when 'underline'
        print_c "\e[4m#{message}\e[24m"
      else
        print_c message
      end
    end
  end

  def display(message)
    print_format("\n# #{message}\n", 'red')
    gets_c.chomp
  end

  def prompt(message, options = false, format = false)
    if options # Make sure the user's option is valid
      while true
        clearScreen()
        print_format("\n# #{message}\n", 'red')
        options.each do |option| # timeall of the options for the user
          print_c "* #{option}"
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
    print_c "@#{name}: \"#{message}\""
  end

  def show_inventory
    user = @controller.getData('user')
    if user == nil
      log "No user has been initialized"
    else
      user = @controller.getData('user')
      inventory = @controller.get_inventory_populated
      if inventory.length == 0
        print_c "*-= INVENTORY IS EMPTY 0/50 =-*"
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
        return []
      else
        print_c "-- SELECT AN ITEM --"
        print_c "-- DO !cancel TO EXIT --"
        response = get_input()
        if response == "!cancel"
          return []
        end
        array = []
        responses = response.split(' ')

        responses.each do |index|
          chosen = inventory[
            index.to_i - 1
          ]

          if index == 0 || !chosen
            display "Item at #{index} does not exist"
          else
            array << chosen
          end
        end

        clearScreen()
        if array.empty?
          return []
        else
          response = prompt("Chosen #{array.map{|i| i['name']}.join(', ')}. Continue?", ["Yes", "No"]);
          if response == 1
            return array
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
        print_c "-- DELETE AN ITEM --"
        print_c "-- DO !cancel TO EXIT --"
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
