# coding: utf-8
require_relative "builtintype"

##
# Represents a Time in the Nial language.
class TimeStamp < BuiltInType

  ##
  # Creates a new TimeStamp.
  def initialize(*args)
    case args.length
    when 1
      case args[0]
      when Number
        @value = args[0].value
      when Float
        @value = args[0]
      else
        @value = 0
      end
    end
  end

  ##
  # Gets called when the user wants to output a TimeStamp to the terminal.
  # Displays the amount of seconds since the Epoch, January 1, 1970 00:00 UTC.
  def display(_,_)
    return Text.new(@value)
  end

  ##
  # Converts the TimeStamp to Text object.
  def convert_to_text(scope, position)
    return Text.new(Time.at(@value).to_s)
  end

  ##
  # Converts the TimeStamp to a Number object.
  def convert_to_number(scope, position)
    return Number.new(Time.at(@value).to_f)
  end

  ##
  # Gets called when the operator - is used and the first operand
  # is a TimeStamp object.
  def subtraction(other, scope, position)
    case other
    when TimeStamp
      return TimeStamp.new(@value.to_f - other.value)
    when Number
      return TimeStamp.new(@value.to_f - other.value)
    end
  end
end
