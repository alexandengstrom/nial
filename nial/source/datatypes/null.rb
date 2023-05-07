# coding: utf-8
require_relative "../exceptions/error"

##
# The class represents the absence of a value in the Nial language. The class is also the baseclass for
# all other datatypes.

class Null
  attr_accessor :line, :column, :constant, :value

  ##
  # Creates a new Null-object.
  def initialize(value)
    @value = value
    @constant = false
  end

  ##
  # Sets the attribute +constant+ to true.
  def make_constant
    @constant = true
  end

  ##
  # Gets called when the operator + is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def addition(other, scope, position)
    return InvalidOperator.new("Can not use addition operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator - is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def subtraction(other, scope, position)
     return InvalidOperator.new("Can not use subtraction operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator * is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def multiplication(other, scope, position)
     return InvalidOperator.new("Can not use multiplication operator between #{self.class} and #{other.class}.", scope, position) 
  end

  ##
  # Gets called when the operator / is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def division(other, scope, position)
     return InvalidOperator.new("Can not use division operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator % is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def modulo(other, scope, position)
     return InvalidOperator.new("Can not use modulo operator between #{self.class} and #{other.class}.", scope, position) 
  end

  ##
  # Gets called when the operator ^ is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def power(other, scope, position)
    return InvalidOperator.new("Can not use exponent operator between #{self.class} and #{other.class}.", scope, position) 
  end

  ##
  # Gets called when the operator == is used. Will return a Boolean with the value true if the other operand
  # also is a Null object, otherwise it returns a Boolean with the value false.
  def equals(other, scope, position)
    if other.class == Null
      return Boolean.new(true)
    else
      return Boolean.new(false)
    end
  end

  ##
  # Gets called when the operator != is used. Will return a Boolean with the value false if the other operand
  # also is a Null object, otherwise it returns a Boolean with the value true.
  def not_equals(other, scope, position)
    if other.class == Null
      return Boolean.new(false)
    else
      return Boolean.new(true)
    end
  end

  ##
  # Gets called when the operator > is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def greater_than(other, scope, position)
     return InvalidOperator.new("Can not use > operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator < is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def less_than(other, scope, position)
     return InvalidOperator.new("Can not use < operator between #{self.class} and #{other.class}.", scope, position) 
  end

  ##
  # Gets called when the operator >= is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def equals_or_greater_than(other, scope, position)
     return InvalidOperator.new("Can not use >= operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator <= is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def equals_or_less_than(other, scope, position)
     return InvalidOperator.new("Can not use <= operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator and is used. Will try to convert both values to Booleans and return true if both are true
  # and false if one of them is false. Can also return the ConversionError exception if one of the operands cannot
  # be converted into a Boolean object.
  def and(other, scope, position)
    new_value = self.convert_to_boolean(scope, position)
    if new_value.is_a?(Error) then return new_value end

    other_value = other.convert_to_boolean(scope, position)
    if other_value.is_a?(Error) then return other_value end

    return Boolean.new(new_value.value && other_value.value)
  end

  ##
  # Gets called when the operator or is used. Will try to convert both values to Booleans and return true
  # if one of the values are true and false if one of them is false.
  # Can also return the ConversionError exception if one of the operands cannot be converted into a Boolean object.
  def or(other, scope, position)
    new_value = self.convert_to_boolean(scope, position)
    if new_value.is_a?(Error) then return new_value end

    other_value = other.convert_to_boolean(scope, position)
    if other_value.is_a?(Error) then return other_value end

    return Boolean.new(new_value.value || other_value.value)
  end

  ##
  # Gets called when the operator not is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def not(other, scope, position)
     return InvalidOperator.new("Can not use not-operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator += is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def addition_assignment(other, scope, position)
    return InvalidOperator.new("Can not use +=-operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator -= is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def subtraction_assignment(other, scope, position)
    return InvalidOperator.new("Can not use -=-operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator /= is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def division_assignment(other, scope, position)
    return InvalidOperator.new("Can not use /=-operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator *= is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def multiplication_assignment(other, scope, position)
    return InvalidOperator.new("Can not use *=-operator between #{self.class} and #{other.class}.", scope, position)
  end

  ##
  # Gets called when the operator call is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def call(arguments, scope, position)
    return InvalidDatatype.new("Invalid datatype, can not call #{self.class}, did you mean to call a method of #{self.class}?", scope, position)
  end

  ##
  # Converts the Null object to a Boolean with the value false.
  def convert_to_boolean(scope, position)
    return Boolean.new(false)
  end

  ##
  # Gets called when an object that cannot be converted to a Function is being converted to a Function.
  # Returns a ConversionError exception.
  def convert_to_function(scope, position)
    return ConversionError.new("Can't convert #{self.class} to Function", scope, position)
  end

  ##
  # Gets called when an object that cannot be converted to a List is being converted to a List.
  # Returns a ConversionError exception.
  def convert_to_list(scope, position)
    return ConversionError.new("Can't convert #{self.class} to List", scope, position)
  end

  ##
  # Gets called when an object that cannot be converted to a Dictionary is being converted to a Dictionary.
  # Returns a ConversionError exception.
  def convert_to_dictionary(scope, position)
    return ConversionError.new("Can't convert #{self.class} to Dictionary", scope, position)
  end

  ##
  # Gets called when an object that cannot be converted to a Text is being converted to a Text.
  # Returns a ConversionError exception.
  def convert_to_text(scope, position)
    return ConversionError.new("Can't convert #{self.class} to Text", scope, position)
  end

  ##
  # Gets called when an object that cannot be converted to a Number is being converted to a Number.
  # Returns a ConversionError exception.
  def convert_to_number(scope, position)
    return ConversionError.new("Can't convert #{self.class} to Number", scope, position)
  end

  ##
  # Gets called when the operator [] is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def set_index(index, new_value, scope, position)
    return InvalidOperator.new("Invalid operator, cannot assign a value to an index of #{self.class}", scope, position)
  end

  ##
  # Gets called when the operator [] is used on a datatype that doesnt support this operator.
  # Returns the InvalidOperator exception.
  def get_index(index, scope, position)
    return InvalidOperator.new("Invalid operator, cannot use index operator on #{self.class}", scope, position)
  end

  ##
  # Gets called when the operator @ is used on a datatype that doesnt have any attributes.
  # Returns the VariableNotDefined exception.
  def get_attribute(attribute, scope, position)
    return VariableNotDefined.new(attribute, scope, position)
  end

  ##
  # Gets called when the user outputs a Null object to the terminal.
  def display(_, _)
    return Text.new("Null")
  end

  ##
  # Returns the type of a object as a Text object.
  def type(scope, position)
    return Text.new(self.class.to_s)
  end

  ##
  # Returns a copy of the Null object.
  def copy(scope, position)
    return Null.new(nil)
  end
  
end
