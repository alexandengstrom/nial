require "test/unit"

require_relative "../../source/datatypes/number"
require_relative "../../source/datatypes/text"
require_relative "../../source/datatypes/boolean"
require_relative "../../source/datatypes/function"
require_relative "../../source/scope/scope"
require_relative "../../source/position/position"

class Test_Boolean < Test::Unit::TestCase
  def test_equals
    position = Position.new(1,1,1)
    scope = Scope.new("scope", nil, position)

    

    x = Boolean.new(true)
    y = Boolean.new(false)
    z = x.equals(y, scope, position)

    assert_false(z.value)

    x = Boolean.new(true)
    y = Boolean.new(true)
    z = x.equals(y, scope, position)

    assert_true(z.value)

    x = Boolean.new(false)
    y = Boolean.new(true)
    z = x.equals(y, scope, position)

    assert_false(z.value)

    x = Boolean.new(false)
    y = Boolean.new(false)
    z = x.equals(y, scope, position)

    assert_true(z.value)

    x = Boolean.new(false)
    y = Number.new(0)
    z = x.equals(y, scope, position)

    assert_true(z.value)

    x = Boolean.new(false)
    y = Number.new(5)
    z = x.equals(y, scope, position)

    assert_false(z.value)
    x = Boolean.new(true)
    y = Number.new(0)
    z = x.equals(y, scope, position)

    assert_false(z.value)

    x = Boolean.new(true)
    y = Number.new(-5)
    z = x.equals(y, scope, position)

    assert_true(z.value)

    x = Boolean.new(true)
    y = Text.new("hello")
    z = x.equals(y, scope, position)

    assert_true(z.value)

    x = Boolean.new(false)
    y = Text.new("hello")
    z = x.equals(y, scope, position)

    assert_false(z.value)

    x = Boolean.new(true)
    y = Text.new("")
    z = x.equals(y, scope, position)

    assert_false(z.value)

    x = Boolean.new(false)
    y = Text.new("")
    z = x.equals(y, scope, position)

    assert_true(z.value)
  end
end
