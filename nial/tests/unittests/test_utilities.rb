# coding: utf-8
require "test/unit"
require_relative "../../source/lexer/lexer"
require_relative "../../source/parser/parser"
require_relative "../../source/interpreter/interpreter"
require_relative "../../source/scope/scope"
require_relative "../../source/position/position"

class Test_Utilities < Test::Unit::TestCase
  def evaluate_file(file, scope)
    data = File.read(file)    
    lexer = Lexer.new
    if (result = lexer.tokenize(data, nil)).is_a?(Error) then return result end
    parser = Parser.new(result)
    if (result = parser.parse).is_a?(Error) then return result end
    result = Interpreter.evaluate(result, scope)
    return result
  end

  def evaluate_attribute_access(statement, scope)
    lexer = Lexer.new
    if (result = lexer.tokenize(statement, nil)).is_a?(Error) then return result end
    parser = Parser.new(result)
    if (result = parser.parse).is_a?(Error) then return result end
    result = Interpreter.evaluate_attribute_access(result.statements[0], scope)
    return result
  end

  def evaluate_method_call(statement, scope)
    lexer = Lexer.new
    if (result = lexer.tokenize(statement, nil)).is_a?(Error) then return result end
    parser = Parser.new(result)
    if (result = parser.parse).is_a?(Error) then return result end
    result = Interpreter.evaluate_method_call(result.statements[0], scope)
    return result
  end

  def test_enum_utility
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/utilitydefinition1.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))
    
    result = evaluate_attribute_access("Action@START", scope)
    assert_true(result.is_a?(Number))
    assert_equal(1, result.value)

    result = evaluate_attribute_access("Action@STOP", scope)
    assert_true(result.is_a?(Number))
    assert_equal(2, result.value)

    result = evaluate_attribute_access("Action@PAUSE", scope)
    assert_true(result.is_a?(Number))
    assert_equal(3, result.value)
  end

  def test_utility
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/utilitydefinition2.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))

    result = evaluate_attribute_access("Math@PI", scope)
    assert_true(result.is_a?(Number))
    assert_equal(3.14, result.value)

    result = evaluate_method_call("call Math.addition(1, 2)", scope)
    assert_true(result.is_a?(Number))
    assert_equal(3, result.value)
  end

  def test_exceptions
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)

    # Utility attributes must be constants
    result = evaluate_file(File.expand_path("../testfiles/utilitydefinition3.nial", __FILE__), scope)
    assert_true(result.is_a?(UnexpectedTokenError))

    # Forgetting stop-keyword
    result = evaluate_file(File.expand_path("../testfiles/utilitydefinition4.nial", __FILE__), scope)
    assert_true(result.is_a?(UnexpectedTokenError))
  end
end
