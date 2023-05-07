require "io/console"

##
# Represents a built in utility in the Nial language for interaction
# with the terminal.
class IOManager < BaseUtility
  ##
  # Gets input from the terminal and returns the result as a Text object.
  def IOManager.input(scope, position)
    print "=> "
    STDIN.flush
    return Text.new(STDIN.gets.chomp)
  end

  ##
  # Calls the method display which every datatype have in their interface
  # and print the result of that operation to the terminal.
  def IOManager.output(value, scope, position)
    result = value.display(scope, position)
    if result.is_a?(Error) then return result end
    result = result.convert_to_text(scope, position)
    if result.is_a?(Error) then return result end

    puts result.value
  end

  ##
  # Return which key is being pressed at a specific moment. If no key
  # is pressed Null is returned. Otherwise the key pressed is returned as
  # a Text object.
  def IOManager.get_key(scope, position)
    key_pressed = self.current_key

    case key_pressed
    when " "
      return Text.new("SPACE")
    when "\t"
      return Text.new("TAB")
    when "\r"
      return Text.new("RETURN")
    when "\n"
      return Text.new("LINE FEED")
    when "\e"
      return Text.new("ESCAPE")
    when "\e[A"
      return Text.new("UP ARROW")
    when "\e[B"
      return Text.new("DOWN ARROW")
    when "\e[C"
      return Text.new("RIGHT ARROW")
    when "\e[D"
      return Text.new("LEFT ARROW")
    when "\177"
      return Text.new("BACKSPACE")
    when "\004"
      return Text.new("DELETE")
    when "\e[3~"
      return Text.new("ALTERNATE DELETE")
    when "\u0003"
      exit 0
    when /^.$/
      return Text.new "CHAR #{key_pressed.inspect}"
    else
      return Null.new(nil)
    end
  end

  private

  def IOManager.current_key
    STDIN.echo = false
    STDIN.raw!

    input = nil
    if IO.select([STDIN], [], [], 0.01)
      STDIN.raw do |stdin|
        input = stdin.getc.chr
        if input == "\e" then
          input << STDIN.read_nonblock(3) rescue nil
          input << STDIN.read_nonblock(2) rescue nil
        end
      end
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end
end
