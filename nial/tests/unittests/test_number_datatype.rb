require "test/unit"
require_relative "../../source/datatypes/number"
require_relative "../../source/datatypes/text"
require_relative "../../source/datatypes/boolean"
require_relative "../../source/datatypes/function"
require_relative "../../source/scope/scope"
require_relative "../../source/position/position"

class Test_Number < Test::Unit::TestCase
  def test_addition
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(3)
    y = Number.new(4)
    z = x.addition(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(7, z.value)

    x = Number.new(-3)
    y = Number.new(-4)
    z = x.addition(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(-7, z.value)

    x = Number.new(3)
    y = Number.new(-4)
    z = x.addition(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(-1, z.value)

    x = Number.new(-3)
    y = Number.new(4)
    z = x.addition(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(1, z.value)

    # Chain expressions.
    x = Number.new(2)
    y = Number.new(2)
    z = x.addition(y, scope, position).addition(y, scope, position).addition(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(8, z.value)

    # Test exceptions
    x = Number.new(3)
    y = Text.new("hello world")
    z = x.addition(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Boolean.new(true)
    z = x.addition(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.addition(y, scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_subtraction
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(3)
    y = Number.new(4)
    z = x.subtraction(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(-1, z.value)

    x = Number.new(-3)
    y = Number.new(-4)
    z = x.subtraction(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(1, z.value)

    x = Number.new(3)
    y = Number.new(-4)
    z = x.subtraction(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(7, z.value)

    x = Number.new(-3)
    y = Number.new(4)
    z = x.subtraction(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(-7, z.value)

    # Test exceptions
    x = Number.new(3)
    y = Text.new("hello world")
    z = x.subtraction(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Boolean.new(true)
    z = x.subtraction(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.subtraction(y, scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_multiplication
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(3)
    y = Number.new(4)
    z = x.multiplication(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(12, z.value)

    x = Number.new(-3)
    y = Number.new(4)
    z = x.multiplication(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(-12, z.value)

    x = Number.new(3)
    y = Number.new(-4)
    z = x.multiplication(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(-12, z.value)

    x = Number.new(-3)
    y = Number.new(-4)
    z = x.multiplication(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(12, z.value)

    # Multiplicate a number with a string
    x = Number.new(3)
    y = Text.new("hello world")
    z = x.multiplication(y, scope, position)
    assert_equal(Text, z.class)
    assert_equal("hello worldhello worldhello world", z.value)

    x = Number.new(-3)
    y = Text.new("hello world")
    z = x.multiplication(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    # Test exceptions
    x = Number.new(3)
    y = Boolean.new(true)
    z = x.multiplication(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.multiplication(y, scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_division
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(10)
    y = Number.new(2)
    z = x.division(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(5, z.value)

    x = Number.new(-10)
    y = Number.new(2)
    z = x.division(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(-5, z.value)

    x = Number.new(10)
    y = Number.new(-2)
    z = x.division(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(-5, z.value)

    x = Number.new(-10)
    y = Number.new(-2)
    z = x.division(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(5, z.value)

    # Convert value to float only when neccesary
    x = Number.new(10)
    y = Number.new(2)
    z = x.division(y, scope, position)
    assert_equal(Integer, z.value.class)

    z = y.division(x, scope, position)
    assert_equal(Float, z.value.class)

    # Test exceptions
    x = Number.new(3)
    y = Text.new("hello world")
    z = x.division(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Boolean.new(true)
    z = x.division(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.division(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Number.new(0)
    z = x.division(y, scope, position)
    assert_equal(DivisionByZero, z.class)
  end

  def test_modulo
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(10)
    y = Number.new(2)
    z = x.modulo(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(0, z.value)

    x = Number.new(10)
    y = Number.new(3)
    z = x.modulo(y, scope, position)
    assert_equal(Number, z.class)
    assert_equal(1, z.value)

    # Test exceptions
    x = Number.new(3)
    y = Text.new("hello world")
    z = x.modulo(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Boolean.new(true)
    z = x.modulo(y, scope, position)
    assert_equal(InvalidOperator, z.class)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.modulo(y, scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_equals
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(10)
    y = Number.new(2)
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(2)
    y = Number.new(2)
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(-2)
    y = Number.new(2)
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(3)
    y = Text.new("hello")
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(5)
    y = Text.new("hello")
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(5)
    y = Boolean.new(true)
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(0)
    y = Boolean.new(true)
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(0)
    y = Boolean.new(false)
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(1)
    y = Boolean.new(false)
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)
  end

  def test_not_equals
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(10)
    y = Number.new(2)
    z = x.not_equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(!false, z.value)

    x = Number.new(2)
    y = Number.new(2)
    z = x.not_equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(!true, z.value)

    x = Number.new(-2)
    y = Number.new(2)
    z = x.not_equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(!false, z.value)

    x = Number.new(3)
    y = Text.new("hello")
    z = x.not_equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(5)
    y = Text.new("hello")
    z = x.not_equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(5)
    y = Boolean.new(true)
    z = x.not_equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(0)
    y = Boolean.new(true)
    z = x.not_equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(0)
    y = Boolean.new(false)
    z = x.not_equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(1)
    y = Boolean.new(false)
    z = x.not_equals(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.not_equals(y, scope, position)
    assert_true(z.value)
  end

  def test_greater_than
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(10)
    y = Number.new(2)
    z = x.greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    z = y.greater_than(x, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(5)
    y = Number.new(5)
    z = x.greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(-5)
    y = Number.new(1)
    z = x.greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(3)
    y = Text.new("hello")
    z = x.greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(5)
    y = Text.new("hello")
    z = x.greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(6)
    y = Text.new("hello")
    z = x.greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.greater_than(y, scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_less_than
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(10)
    y = Number.new(2)
    z = x.less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(!true, z.value)

    z = y.less_than(x, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(!false, z.value)

    x = Number.new(5)
    y = Number.new(5)
    z = x.less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(-5)
    y = Number.new(1)
    z = x.less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(!false, z.value)

    x = Number.new(3)
    y = Text.new("hello")
    z = x.less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(5)
    y = Text.new("hello")
    z = x.less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(6)
    y = Text.new("hello")
    z = x.less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.less_than(y, scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_equals_or_greater_than
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(10)
    y = Number.new(2)
    z = x.equals_or_greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(10)
    y = Number.new(10)
    z = x.equals_or_greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(10)
    y = Number.new(11)
    z = x.equals_or_greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(10)
    y = Number.new(-20)
    z = x.equals_or_greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(3)
    y = Text.new("hello")
    z = x.equals_or_greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(5)
    y = Text.new("hello")
    z = x.equals_or_greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(6)
    y = Text.new("hello")
    z = x.equals_or_greater_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.equals_or_greater_than(y, scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_equals_or_less_than
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(10)
    y = Number.new(11)
    z = x.equals_or_less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(10)
    y = Number.new(10)
    z = x.equals_or_less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(10)
    y = Number.new(9)
    z = x.equals_or_less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(10)
    y = Number.new(-20)
    z = x.equals_or_less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)
    
    x = Number.new(3)
    y = Text.new("hello")
    z = x.equals_or_less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(5)
    y = Text.new("hello")
    z = x.equals_or_less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)

    x = Number.new(6)
    y = Text.new("hello")
    z = x.equals_or_less_than(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(false, z.value)

    x = Number.new(3)
    y = Function.new(nil, nil, nil)
    z = x.equals_or_less_than(y, scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_and
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(3)
    y = Number.new(4)
    z = x.and(y, scope, position)
    assert_equal(Boolean, z.class)
    assert_equal(true, z.value)
  end

  def test_square_root
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(9)
    z = x.square_root(scope, position)
    assert_equal(Number, z.class)
    assert_equal(3, z.value)

    x = Number.new(16)
    z = x.square_root(scope, position)
    assert_equal(Number, z.class)
    assert_equal(4, z.value)

    x = Number.new(0)
    z = x.square_root(scope, position)
    assert_equal(Number, z.class)
    assert_equal(0, z.value)

    x = Number.new(10000)
    z = x.square_root(scope, position)
    assert_equal(Number, z.class)
    assert_equal(100, z.value)

    x = Number.new(-10)
    z = x.square_root(scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_power
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(2)
    z = x.power(Number.new(2), scope, position)
    assert_equal(Number, z.class)
    assert_equal(4, z.value)

    z = x.power(Number.new(4), scope, position)
    assert_equal(Number, z.class)
    assert_equal(16, z.value)

    z = x.power(Number.new(-2), scope, position)
    assert_equal(Number, z.class)
    assert_equal(0.25, z.value)

    x = Number.new(-2)
    z = x.power(Number.new(2), scope, position)
    assert_equal(Number, z.class)
    assert_equal(4, z.value)

    z = x.power(Number.new(3), scope, position)
    assert_equal(Number, z.class)
    assert_equal(-8, z.value)

    x = Number.new(3)
    z = x.power(Text.new("hej"), scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_factorial
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(2)
    z = x.factorial(scope, position)
    assert_equal(Number, z.class)
    assert_equal(2, z.value)

    x = Number.new(4)
    z = x.factorial(scope, position)
    assert_equal(Number, z.class)
    assert_equal(24, z.value)

    x = Number.new(10)
    z = x.factorial(scope, position)
    assert_equal(Number, z.class)
    assert_equal(3628800, z.value)

    x = Number.new(0)
    z = x.factorial(scope, position)
    assert_equal(Number, z.class)
    assert_equal(1, z.value)

    x = Number.new(-2)
    z = x.factorial(scope, position)
    assert_equal(InvalidOperator, z.class)
  end

  def test_round
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(3.1415)
    z = x.round(Number.new(3), scope, position)
    assert_equal(Number, z.class)
    assert_equal(3.142, z.value)

    z = x.round(Number.new(2), scope, position)
    assert_equal(Number, z.class)
    assert_equal(3.14, z.value)

    z = x.round(Number.new(1), scope, position)
    assert_equal(Number, z.class)
    assert_equal(3.1, z.value)

    z = x.round(Number.new(0), scope, position)
    assert_equal(Number, z.class)
    assert_equal(3, z.value)

    z = x.round(Number.new(-1), scope, position)
    assert_equal(Number, z.class)
    assert_equal(0, z.value)

    x = Number.new(12345.12345)
    z = x.round(Number.new(1), scope, position)
    assert_equal(Number, z.class)
    assert_equal(12345.1, z.value)

    z = x.round(Number.new(-1), scope, position)
    assert_equal(Number, z.class)
    assert_equal(12350, z.value)

    z = x.round(Number.new(-2), scope, position)
    assert_equal(Number, z.class)
    assert_equal(12300, z.value)

    z = x.round(Number.new(-3), scope, position)
    assert_equal(Number, z.class)
    assert_equal(12000, z.value)

    z = x.round(Number.new(-4), scope, position)
    assert_equal(Number, z.class)
    assert_equal(10000, z.value)

    z = x.round(Number.new(-5), scope, position)
    assert_equal(Number, z.class)
    assert_equal(0, z.value)

    z = x.round(Number.new(-500), scope, position)
    assert_equal(Number, z.class)
    assert_equal(0, z.value)

  end

  def test_absolute_value
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = Number.new(3.1415)
    z = x.absolute_value(scope, position)
    assert_equal(Number, z.class)
    assert_equal(3.1415, z.value)

    x = Number.new(-3.1415)
    z = x.absolute_value(scope, position)
    assert_equal(Number, z.class)
    assert_equal(3.1415, z.value)

    x = Number.new(0)
    z = x.absolute_value(scope, position)
    assert_equal(Number, z.class)
    assert_equal(0, z.value)
  end
end
