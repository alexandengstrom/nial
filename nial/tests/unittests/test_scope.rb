require "test/unit"
require_relative "../../source/token/token"
require_relative "../../source/datatypes/number"
require_relative "../../source/datatypes/text"
require_relative "../../source/scope/scope"
require_relative "../../source/scope/function_scope"
require_relative "../../source/position/position"

class Test_Scope < Test::Unit::TestCase
  def test_scope
    position = Position.new(1,1,1)

    # Test that variable assigned in the global scope can be reached in other scopes.
    scope1 = Scope.new("scope1", nil, position)
    scope2 = Scope.new("scope2", scope1, position)
    scope3 = Scope.new("scope3", scope2, position)
    identifier = Token.new(:IDENTIFIER, "x", 1,1, nil)
    value = Number.new(5)
    scope1.set_variable(identifier, value)

    assert_equal(Number, scope1.get_variable(identifier).class)
    assert_equal(5, scope1.get_variable(identifier).value)
    assert_equal(Number, scope2.get_variable(identifier).class)
    assert_equal(5, scope2.get_variable(identifier).value)
    assert_equal(Number, scope3.get_variable(identifier).class)
    assert_equal(5, scope3.get_variable(identifier).value)

    # Test that variable defined in the second scope can be reached in second and third scope but not in the global scope.
    identifier = Token.new(:IDENTIFIER, "y", 1,1, nil)
    value = Number.new(6)
    scope2.set_variable(identifier, value)

    assert_equal(VariableNotDefined, scope1.get_variable(identifier).class)
    assert_equal(Number, scope2.get_variable(identifier).class)
    assert_equal(6, scope2.get_variable(identifier).value)
    assert_equal(Number, scope3.get_variable(identifier).class)
    assert_equal(6, scope3.get_variable(identifier).value)

    # Test that the same works for textobjects.
    identifier = Token.new(:IDENTIFIER, "z", 1,1, nil)
    value = Text.new("hello world")
    scope2.set_variable(identifier, value)

    assert_equal(VariableNotDefined, scope1.get_variable(identifier).class)
    assert_equal(Text, scope2.get_variable(identifier).class)
    assert_equal("hello world", scope2.get_variable(identifier).value)
    assert_equal(Text, scope3.get_variable(identifier).class)
    assert_equal("hello world", scope3.get_variable(identifier).value)

    # Test that assigning variable x in third scope changes the variable x in first scope.
    identifier = Token.new(:IDENTIFIER, "x", 1,1, nil)
    value = Text.new("hello world")
    scope2.set_variable(identifier, value)

    assert_equal(Text, scope1.get_variable(identifier).class)
    assert_equal("hello world", scope2.get_variable(identifier).value)
    assert_equal(Text, scope2.get_variable(identifier).class)
    assert_equal("hello world", scope2.get_variable(identifier).value)
    assert_equal(Text, scope3.get_variable(identifier).class)
    assert_equal("hello world", scope3.get_variable(identifier).value)

    # Add a new functionscope, the function scope should only be able to access variables in its own scope and the global scope
    scope4 = FunctionScope.new("scope4", scope2, position)

    assert_equal(Text, scope4.get_variable(identifier).class)
    assert_equal("hello world", scope2.get_variable(identifier).value)

    # Should not be able to access y in the second scope
    identifier = Token.new(:IDENTIFIER, "y", 1,1, nil)
    assert_equal(VariableNotDefined, scope4.get_variable(identifier).class)

    # But can define a new variable y in its own scope. Now the function scope should get 1 when asking for y but scope 3 should get 6.
    identifier = Token.new(:IDENTIFIER, "y", 1,1, nil)
    value = Number.new(1)
    scope4.set_variable(identifier, value)
    assert_equal(Number, scope4.get_variable(identifier).class)
    assert_equal(1, scope4.get_variable(identifier).value)
    assert_equal(Number, scope3.get_variable(identifier).class)
    assert_equal(6, scope3.get_variable(identifier).value)

    # If a new scope is added on top of the function scope it should also get the value 1 when asking for y
    scope5 = Scope.new("scope5", scope4, position)
    assert_equal(Number, scope5.get_variable(identifier).class)
    assert_equal(1, scope5.get_variable(identifier).value)

    # Scope 5 should not be able to find z.
    identifier = Token.new(:IDENTIFIER, "z", 1,1, nil)
    assert_equal(VariableNotDefined, scope5.get_variable(identifier).class)
    
    
  end
end
