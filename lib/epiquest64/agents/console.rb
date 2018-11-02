require 'ffi-ncurses'
require_relative '../util/func'
include FFI::NCurses

$USE_NCURSES = ARGV.delete('--use-ncurses')

$border_main_win = nil
$border_choice_win = nil
$border_stats_win = nil
$main_win = nil
$choice_win = nil
$stats_win = nil

def print_c(s, win: $main_win, nl: true)
  if $USE_NCURSES
    if nl then s += "\n" end
    wprintw win, s
    wrefresh win
  else
    if nl
      puts s
    else
      print s
    end
  end
end

def gets_c()
  if $USE_NCURSES
    # getstr don't work D:
    s = ''
    while true
      c = wgetch $choice_win
      if c.chr == "\n" then break end
        s += c.chr
      end
    wclear $choice_win
    wrefresh $choice_win
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

      $stats_win = newwin 5, 100, 1, 1
      $main_win = newwin 20, 100, 8, 1
      $choice_win = newwin 5, 100, 30, 1

      $border_stats_win = newwin 7, 102, 0, 0
      $border_main_win = newwin 22, 102, 7, 0
      $border_choice_win = newwin 7, 102, 29, 0

      box $border_stats_win, 0, 0
      box $border_main_win, 0, 0
      box $border_choice_win, 0, 0

      wrefresh $border_stats_win
      wrefresh $border_main_win
      wrefresh $border_choice_win
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

  def update_stats
    user = @controller.getData 'user'

    if $USE_NCURSES
      wclear $stats_win
      wprintw $stats_win, "Name: #{user.name}\nMoney: #{@func.to_readable_money(user.money)}\nFishing rod health: #{user.fishingRod.health}\nXP: #{user.xp}\nLevel: #{user.level}"
      wrefresh $stats_win
    end
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

    wclear $choice_win
    print_c "response > ", nl: false, win: $choice_win
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
      wclear $main_win
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

  def display(message, wait = true)
    print_format("\n# #{message}\n", 'red')
    gets_c.chomp if wait
  end

  def variant_select(vars)
    wclear $choice_win
    vars.each_with_index do |v, i|
      mvwprintw $choice_win, i, 2, v
    end
    i = 0
    keypad $choice_win, true
    curs_set 0
    noecho
    while true
      mvwprintw $choice_win, i, 0, '>'
      c = wgetch $choice_win
      case c
      when KEY_UP
        mvwprintw $choice_win, i, 0, ' '
        i = if i == 0 then vars.length - 1 else i - 1 end
      when KEY_DOWN
        mvwprintw $choice_win, i, 0, ' '
        i = if i + 1 == vars.length then 0 else i + 1 end
      when "\n".ord
        break
      end
    end
    keypad $choice_win, false
    curs_set 1
    echo
    wclear $choice_win
    wrefresh $choice_win
    return i
  end

  def prompt(message, options = false, format = false)
    if options # Make sure the user's option is valid
      if $USE_NCURSES
        clearScreen
        print_format("\n# #{message}\n", 'red')
        return variant_select(options) + 1
      else
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
