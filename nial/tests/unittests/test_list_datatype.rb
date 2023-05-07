require "test/unit"
require_relative "../../source/datatypes/number"
require_relative "../../source/datatypes/text"
require_relative "../../source/datatypes/boolean"
require_relative "../../source/datatypes/function"
require_relative "../../source/scope/scope"
require_relative "../../source/datatypes/list"
require_relative "../../source/position/position"

class Test_List < Test::Unit::TestCase
  def test_list
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    assert_true(x.value.is_a?(Array))
    assert_equal(0, x.value.length)
                
    x.add(Number.new(1))
    assert_equal(1, x.value.length)
    assert_equal(1, x.value[0].value)

    x.add(Number.new(5))
    assert_equal(2, x.value.length)
    assert_equal(1, x.value[0].value)
    assert_equal(5, x.value[1].value)

    x.add(Boolean.new(true))
    assert_equal(3, x.value.length)
    assert_equal(1, x.value[0].value)
    assert_equal(5, x.value[1].value)
    assert_equal(true, x.value[2].value)

    assert_equal(1, x.get_index(Number.new(1), nil, position).value)
    assert_equal(5, x.get_index(Number.new(2), nil, position).value)
    assert_equal(true, x.get_index(Number.new(3), nil, position).value)

    x.set_index(Number.new(2), Boolean.new(false), nil, position)
    assert_equal(1, x.get_index(Number.new(1), nil, position).value)
    assert_equal(false, x.get_index(Number.new(2), nil, position).value)
    assert_equal(true, x.get_index(Number.new(3), nil, position).value)

    assert_equal("[1, False, True]", x.display(scope, position).value)
  end

  def test_append
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    assert_equal(Number, x.value[0].class)
    assert_equal(1, x.value.length)

    x.append(Boolean.new(true), scope, position)
    assert_equal(Boolean, x.value[1].class)
    assert_equal(2, x.value.length)

    x.append(Text.new("hello world"), scope, position)
    assert_equal(Text, x.value[2].class)
    assert_equal(3, x.value.length)

    assert_equal("[1, True, hello world]", x.display(scope, position).value)
  end

  def test_pop
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    x.append(Number.new(2), scope, position)
    x.append(Number.new(3), scope, position)
    x.append(Number.new(4), scope, position)
    x.append(Number.new(5), scope, position)
    assert_equal(5, x.value.length)
    assert_equal(5, x.value[-1].value)

    y = x.pop(scope, position)
    assert_equal(4, x.value.length)
    assert_equal(4, x.value[-1].value)
    assert_equal(5, y.value)

    y =x.pop(scope, position)
    assert_equal(3, x.value.length)
    assert_equal(3, x.value[-1].value)
    assert_equal(4, y.value)

    y = x.pop(scope, position)
    assert_equal(2, x.value.length)
    assert_equal(2, x.value[-1].value)
    assert_equal(3, y.value)

    y = x.pop(scope, position)
    assert_equal(1, x.value.length)
    assert_equal(1, x.value[-1].value)
    assert_equal(2, y.value)

    y = x.pop(scope, position)
    assert_equal(0, x.value.length)
    assert_equal(1, y.value)

    y = x.pop(scope, position)
    assert_equal(0, x.value.length)
    assert_equal(Null, y.class)
  end

  def test_has_value
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    x.append(Text.new("test"), scope, position)
    x.append(Number.new(3), scope, position)
    x.append(Boolean.new(false), scope, position)
    x.append(Number.new(5), scope, position)
    
    y = x.has_value(Number.new(5), scope, position)
    assert_true(y.is_a?(Boolean))
    assert_equal(true, y.value)

    y = x.has_value(Number.new(7), scope, position)
    assert_true(y.is_a?(Boolean))
    assert_equal(false, y.value)

    y = x.has_value(Text.new("test2"), scope, position)
    assert_true(y.is_a?(Boolean))
    assert_equal(false, y.value)

    y = x.has_value(Text.new("test"), scope, position)
    assert_true(y.is_a?(Boolean))
    assert_equal(true, y.value)

    y = x.has_value(Boolean.new(true), scope, position)
    assert_true(y.is_a?(Boolean))
    assert_equal(false, y.value)

    y = x.has_value(Boolean.new(false), scope, position)
    assert_true(y.is_a?(Boolean))
    assert_equal(true, y.value)
  end

  def test_first
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    x.append(Text.new("test"), scope, position)
    x.append(Number.new(3), scope, position)
    x.append(Boolean.new(false), scope, position)
    x.append(Number.new(5), scope, position)
    
    y = x.first(scope, position)
    assert_true(y.is_a?(Number))
    assert_equal(1, y.value)

    x = List.new
    y = x.first(scope, position)
    assert_true(y.is_a?(Null))
  end

  def test_last
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    x.append(Text.new("test"), scope, position)
    x.append(Number.new(3), scope, position)
    x.append(Boolean.new(false), scope, position)
    x.append(Number.new(5), scope, position)
    
    y = x.last(scope, position)
    assert_true(y.is_a?(Number))
    assert_equal(5, y.value)

    x = List.new
    y = x.last(scope, position)
    assert_true(y.is_a?(Null))
  end

  def test_join
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    x.append(Number.new(2), scope, position)
    x.append(Number.new(3), scope, position)
    x.append(Number.new(4), scope, position)
    x.append(Number.new(5), scope, position)

    y = x.join(Text.new("test"), scope, position)
    assert_true(y.is_a?(Text))
    assert_equal("1test2test3test4test5", y.value)

    x = List.new
    x.append(Number.new(1), scope, position)
    y = x.join(Text.new("test"), scope, position)
    assert_true(y.is_a?(Text))
    assert_equal("1", y.value)

    y = x.join(Number.new(2), scope, position)
    assert_true(y.is_a?(InvalidDatatype))              
  end

  def test_flip
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    x.append(Number.new(2), scope, position)
    x.append(Number.new(3), scope, position)
    x.append(Number.new(4), scope, position)
    x.append(Number.new(5), scope, position)

    y = x.display(scope, position).value
    assert_equal("[1, 2, 3, 4, 5]", y)
    y = x.flip(scope, position)
    assert_true(y.is_a?(List))
    y = y.display(scope, position).value
    assert_equal("[5, 4, 3, 2, 1]", y)

    x = List.new
    y = x.display(scope, position).value
    assert_equal("[]", y)
    y = x.flip(scope, position)
    assert_true(y.is_a?(List))
    y = y.display(scope, position).value
    assert_equal("[]", y)
  end

  def test_clear
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    x.append(Number.new(2), scope, position)
    x.append(Number.new(3), scope, position)
    x.append(Number.new(4), scope, position)
    x.append(Number.new(5), scope, position)

    assert_equal(5, x.value.length)
    x.clear(scope, position)
    assert_equal(0, x.value.length)
    x.clear(scope, position)
    assert_equal(0, x.value.length)
  end

  def test_empty
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    x.append(Number.new(2), scope, position)
    x.append(Number.new(3), scope, position)
    x.append(Number.new(4), scope, position)
    x.append(Number.new(5), scope, position)

    y = x.empty(scope, position)
    assert_true(y.is_a?(Boolean))
    assert_false(y.value)

    x.clear(scope, position)
    y = x.empty(scope, position)
    assert_true(y.is_a?(Boolean))
    assert_true(y.value)  
  end

  def test_insert
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    
    x = List.new
    x.append(Number.new(1), scope, position)
    x.append(Number.new(2), scope, position)
    x.append(Number.new(3), scope, position)

    y = x.display(scope, position).value
    assert_equal("[1, 2, 3]", y)

    x.insert(Number.new(2), Text.new("new string"), scope, position)
    y = x.display(scope, position).value
    assert_equal("[1, new string, 2, 3]", y)

    x.insert(Number.new(10), Number.new(10), scope, position)
    y = x.display(scope, position).value
    assert_equal("[1, new string, 2, 3, 10]", y)

    x.insert(Number.new(-100), Number.new(2.2), scope, position)
    y = x.display(scope, position).value
    assert_equal("[2.2, 1, new string, 2, 3, 10]", y)

    x.insert(Number.new(-1), Number.new(2), scope, position)
    y = x.display(scope, position).value
    assert_equal("[2.2, 1, new string, 2, 3, 2, 10]", y)
  end
end
