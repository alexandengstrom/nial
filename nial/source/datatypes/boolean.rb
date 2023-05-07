require_relative "null"
##
# Represents a boolean value in the Nial language

class Boolean < Null

  ##
  # Creates a boolean with the value true or false
  def initialize(value)
    super(value)
  end

  ##
  # The display method is called every time the object is being
  # printed to the terminal
  def display(_, _)
    if @value then return Text.new("True") else return Text.new("False") end
  end

  ##
  # The method gets called when the == operator is used on a Boolean-object
  def equals(other, scope, position)
    other = other.convert_to_boolean(scope, position)
    if other.is_a?(Error) then return other end
    return Boolean.new(@value == other.value)
  end

  ##
  # The method gets called when the != operator is used on a Boolean-object
  def not_equals(other, scope, position)
    other = other.convert_to_boolean(scope, position)
    if other.is_a?(Error) then return other end
    return Boolean.new(@value != other.value)
  end

  ##
  # The method gets called when the and operator is used on a Boolean-object
  def and(other, scope, position)
    other = other.convert_to_boolean(scope, position)
    if other.is_a?(Error) then return other end
    return Boolean.new(@value && other.value)
  end

  ##
  # The method gets called when the or operator is used on a Boolean-object
  def or(other, scope, position)
    other = other.convert_to_boolean(scope, position)
    if other.is_a?(Error) then return other end
    return Boolean.new(@value || other.value)
  end

  ##
  # The method gets called when the program needs a boolean, for example in if-statements and while-loops.
  # The boolean object will return itself in this method.
  def convert_to_boolean(scope, position)
    return self
  end

  ##
  # Converts the boolean to a Number object. 1 if the value is true and 0 if the value is false.
  def convert_to_number(scope, position)
    if @value then return Number.new(1) end
    return Number.new(0)
  end

  ##
  # Returns a copy of the boolean.
  def copy(scope, position)
    return Boolean.new(@value)
  end
end
