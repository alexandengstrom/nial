require_relative "baseutility"
require_relative "../list"
require_relative "../text"

##
# Represents a built in utility in the Nial language.
# Lets the user interact with the system.
class SystemManager
  @@attributes = Hash.new

  ##
  # Collects the arguments from ARGV and the current platform.
  def SystemManager.setup()
    arguments = List.new
    ARGV.each {|arg|
      arguments.add(Text.new(arg))
    }
    @@attributes["ARGUMENTS"] = arguments
    @@attributes["PLATFORM"] = Text.new(RUBY_PLATFORM)
  end

  ##
  # Executes the command provided as parameter. The command
  # parameter will be converted to Text and will return
  # ConversionError exception if that operation fails.
  def SystemManager.execute(command, scope, position)
    command = command.convert_to_text(scope, position)
    if command.is_a?(Error) then return command end
    system(command.value)
    return Null.new(nil)
  end

  ##
  # Exits the entire program.
  def SystemManager.exit(scope, position)
    abort
  end

  ##
  # Sleeps the program. The parameter time will be converted to
  # a Number object and returns ConversionError exception if that
  # operation fails. 
  def SystemManager.wait(time, scope, position)
    time = time.convert_to_number(scope, position)
    if time.is_a?(Error) then return time end
    sleep(time.value)
    return Null.new(nil)
  end

  ##
  # Gets called when the operator @ is used. Returns the
  # attribute if it exists in the @@attributes hash.
  # Otherwise returns ConstantNotDefined exception.
  def SystemManager.get_attribute(attribute, scope, position)
    if @@attributes.has_key?(attribute.value)
      return @@attributes[attribute.value].copy(scope, position)
    end
    return ConstantNotDefined.new(self.class, attribute, scope, position)
  end
end
