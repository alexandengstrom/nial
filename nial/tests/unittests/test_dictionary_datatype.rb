require "test/unit"
require_relative "../../source/datatypes/number"
require_relative "../../source/datatypes/text"
require_relative "../../source/datatypes/boolean"
require_relative "../../source/datatypes/dictionary"
require_relative "../../source/datatypes/function"
require_relative "../../source/scope/scope"
require_relative "../../source/datatypes/list"
require_relative "../../source/position/position"

class Test_List < Test::Unit::TestCase
  def test_dictionary_constructor
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)

    dict = Dictionary.new([])
    assert_true(dict.length(scope, position).is_a?(Number))

    key = Text.new("key")
    value = Number.new(10)
    dict = Dictionary.new([[key, value]])
    assert_true(dict.length(scope, position).is_a?(Number))
    assert_true(dict.value[0][0].is_a?(Text))
    assert_true(dict.value[0][1].is_a?(Number))
  end

  def test_set_index
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)

    dict = Dictionary.new([])
    key = Text.new("key")
    value = Number.new(10)
    dict.set_index(key, value, scope, position)
    assert_true(dict.length(scope, position).is_a?(Number))
    assert_true(dict.value[0][0].is_a?(Text))
    assert_true(dict.value[0][1].is_a?(Number))
    assert_equal(10, dict.value[0][1].value)

    dict.set_index(key, Number.new(0), scope, position)
    assert_true(dict.length(scope, position).is_a?(Number))
    assert_true(dict.value[0][0].is_a?(Text))
    assert_true(dict.value[0][1].is_a?(Number))
    assert_equal(0, dict.value[0][1].value)

    dict.set_index(Text.new("new key"), Number.new(3), scope, position)
    assert_true(dict.length(scope, position).is_a?(Number))
    assert_true(dict.value[0][0].is_a?(Text))
    assert_true(dict.value[0][1].is_a?(Number))
    assert_true(dict.value[1][0].is_a?(Text))
    assert_true(dict.value[1][1].is_a?(Number))
    assert_equal(0, dict.value[0][1].value)
    assert_equal(3, dict.value[1][1].value)
  end

  def test_get_index
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)

    key1 = Text.new("one")
    value1 = Number.new(1)
    key2 = Text.new("two")
    value2 = Number.new(2)
    key3 = Text.new("three")
    value3 = Number.new(3)
    dict = Dictionary.new([[key1, value1], [key2, value2], [key3, value3]])

    assert_true(dict.get_index(key1, scope, position).is_a?(Number))
    assert_equal(1, dict.get_index(key1, scope, position).value)

    assert_true(dict.get_index(key2, scope, position).is_a?(Number))
    assert_equal(2, dict.get_index(key2, scope, position).value)

    assert_true(dict.get_index(key3, scope, position).is_a?(Number))
    assert_equal(3, dict.get_index(key3, scope, position).value)                        
  end

  def test_get_keys
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)

    key1 = Text.new("one")
    value1 = Number.new(1)
    key2 = Text.new("two")
    value2 = Number.new(2)
    key3 = Text.new("three")
    value3 = Number.new(3)
    dict = Dictionary.new([[key1, value1], [key2, value2], [key3, value3]])

    result = dict.get_keys(scope, position)
    assert_true(result.is_a?(List))
    assert_equal(3, result.value.length)
    assert_equal("one", result.value[0].value)
    assert_equal("two", result.value[1].value)
    assert_equal("three", result.value[2].value)
  end

  def test_get_values
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)

    key1 = Text.new("one")
    value1 = Number.new(1)
    key2 = Text.new("two")
    value2 = Number.new(2)
    key3 = Text.new("three")
    value3 = Number.new(3)
    dict = Dictionary.new([[key1, value1], [key2, value2], [key3, value3]])

    result = dict.get_values(scope, position)
    assert_true(result.is_a?(List))
    assert_equal(3, result.value.length)
    assert_equal(1, result.value[0].value)
    assert_equal(2, result.value[1].value)
    assert_equal(3, result.value[2].value)
  end

  def test_get_pairs
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)

    key1 = Text.new("one")
    value1 = Number.new(1)
    key2 = Text.new("two")
    value2 = Number.new(2)
    key3 = Text.new("three")
    value3 = Number.new(3)
    dict = Dictionary.new([[key1, value1], [key2, value2], [key3, value3]])

    result = dict.get_pairs(scope, position)
    assert_true(result.is_a?(List))
    assert_equal(3, result.value.length)
    assert_true(result.is_a?(List))
    assert_true(result.value[0].is_a?(List))
    assert_true(result.value[0].value[0].is_a?(Text))
    assert_true(result.value[0].value[1].is_a?(Number))
    assert_true(result.value[1].value[0].is_a?(Text))
    assert_true(result.value[1].value[1].is_a?(Number))
    assert_true(result.value[2].value[0].is_a?(Text))
    assert_true(result.value[2].value[1].is_a?(Number))
  end

  def test_length
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)

    dict = Dictionary.new([])
    assert_true(dict.length(scope, position).is_a?(Number))
    assert_equal(0, dict.length(scope, position).value)

    key1 = Text.new("one")
    value1 = Number.new(1)
    key2 = Text.new("two")
    value2 = Number.new(2)
    key3 = Text.new("three")
    value3 = Number.new(3)
    dict = Dictionary.new([[key1, value1], [key2, value2], [key3, value3]])

    assert_true(dict.length(scope, position).is_a?(Number))
    assert_equal(3, dict.length(scope, position).value)
  end

  def test_convert_to_boolean
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)

    dict = Dictionary.new([])
    assert_true(dict.convert_to_boolean(scope, position).is_a?(Boolean))
    assert_equal(false, dict.convert_to_boolean(scope, position).value)

    key1 = Text.new("one")
    value1 = Number.new(1)
    key2 = Text.new("two")
    value2 = Number.new(2)
    key3 = Text.new("three")
    value3 = Number.new(3)
    dict = Dictionary.new([[key1, value1], [key2, value2], [key3, value3]])
    assert_true(dict.convert_to_boolean(scope, position).is_a?(Boolean))
    assert_equal(true, dict.convert_to_boolean(scope, position).value)
  end
end
