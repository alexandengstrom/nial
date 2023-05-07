require_relative "null"
require_relative "boolean"

#
# This class represents a number in the language.
class Number < Null

  ##
  # Creates a new Number
  def initialize(value)
    super(value)
  end

  ##
  # Gets called when the operator + is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def addition(other, scope, position)
    case other
    when Number
      return Number.new(@value + other.value)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator - is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def subtraction(other, scope, position)
    case other
    when Number
      return Number.new(@value - other.value)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator * is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def multiplication(other, scope, position)
    case other
    when Number
      return Number.new(@value * other.value)
    when Text
      if self.value < 0
        return InvalidOperator.new("Number cannot be a negative value when using multiplication operator between  #{self.class} and #{other.class}.", scope, position)
      end
      return Text.new(other.value * @value)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator / is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype. Can also return DivisionByZero
  # exception.
  def division(other, scope, position)
    case other
    when Number
      if other.value == 0
        return DivisionByZero.new("Division by zero", scope, position)
      end
      if @value % other.value != 0
        return Number.new(@value.to_f / other.value)
      end
      return Number.new(@value / other.value)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator % is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def modulo(other, scope, position)
    case other
    when Number
      return Number.new(@value % other.value)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator == is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def equals(other, scope, position)
    case other
    when Number
      return Boolean.new(@value == other.value)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator != is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def not_equals(other, scope, position)
    case other
    when Number
      return Boolean.new(@value != other.value)
    when Text
      return Boolean.new(@value != other.value.length)
    when Boolean
      bool = self.convert_to_boolean(scope, position)
      return Boolean.new(bool.value != other.value)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator > is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def greater_than(other, scope, position)
    case other
    when Number
      return Boolean.new(@value > other.value)
    when Text
      return Boolean.new(@value > other.value.length)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator < is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def less_than(other, scope, position)
    case other
    when Number
      return Boolean.new(@value < other.value)
    when Text
      return Boolean.new(@value < other.value.length)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator >= is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def equals_or_greater_than(other, scope, position)
    case other
    when Number
      return Boolean.new(@value >= other.value)
    when Text
      return Boolean.new(@value >= other.value.length)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator <= is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def equals_or_less_than(other, scope, position)
    case other
    when Number
      return Boolean.new(@value <= other.value)
    when Text
      return Boolean.new(@value <= other.value.length)
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator += is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def addition_assignment(other, scope, position)
    case other
    when Number
      @value += other.value
      return self
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator -= is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def subtraction_assignment(other, scope, position)
    case other
    when Number
      @value -= other.value
      return self
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator /= is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def division_assignment(other, scope, position)
    case other
    when Number
      if other.value == 0
        return DivisionByZero.new("Division by zero", scope, position)
      else
        if @value % other.value != 0
          @value.to_f /= other.value
        else
          @value /= other.value
        end
      end
      return self
    else
      return super(other, scope, position)
    end
  end

  ##
  # Gets called when the operator *= is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def multiplication_assignment(other, scope, position)
    case other
    when Number
      @value *= other.value
      return self
    else
      return super(other, scope, position)
    end
  end

  ##
  # Converts the Number object to a Boolean object. Returns False if the number
  # is 0, else True.
  def convert_to_boolean(scope, position)
    if @value == 0 then return Boolean.new(false) end
    return Boolean.new(true)
  end

  ##
  # Convert the Number to a Text object.
  def convert_to_text(scope, position)
    return Text.new("#{@value}")
  end

  ##
  # Returns itself
  def convert_to_number(scope, position)
    return self
  end

  ##
  # Returns a copy of the Number object.
  def copy(scope, position)
    return Number.new(@value)
  end

  ##
  # Gets called when the user wants to output a Number object to the terminal.
  def display(_, _)
    return Text.new("#{@value}")
  end

  ##
  # Returns the square root of the Number as a new Number object.
  def square_root(scope, position)
    if @value < 0
      return InvalidOperator.new("Cannot take the square root of a negative number", scope, position)
    end
    return Number.new(Math.sqrt(@value))
  end

  ##
  # Gets called when the operator ^ is used and a Number is the first operand.
  # Calls superclass if Number cannot handle the operation
  # with the other operands datatype.
  def power(other, scope, position)
    case other
    when Number
      return Number.new(@value.pow(other.value))
    else
      return super(other, scope, position)
    end
  end

  ##
  # Returns the factorial of the Number as a new Number object.
  def factorial(scope, position)
    if @value == 0 then return Number.new(1)
    elsif @value < 0
      return InvalidOperator.new("Cannot calculate the factorial of a negative number", scope, position)
    else
      return Number.new((1..@value).inject(:*))
    end
  end

  ##
  # Rounds the Number to number amount of decimals.
  def round(number, scope, position)
    number = number.convert_to_number(scope, position)
    if number.is_a?(Error) then return number end
    return Number.new(@value.round(number.value))
  end

  ##
  # Returns the absolute value of the Number as a new Number object.
  def absolute_value(scope, position)
    return Number.new(@value.abs)
  end

  ##
  # Returns the cosine of the Number as a new Number object.
  def cosine(scope, position)
    return Number.new(Math.cos(@value))
  end

  ##
  # Returns the sine of the Number as a new Number object.
  def sine(scope, position)
    return Number.new(Math.sin(@value))
  end

  ##
  # Returns the tangent of the Number as a new Number object.
  def tangent(scope, position)
    return Number.new(Math.tan(@value))
  end

end
