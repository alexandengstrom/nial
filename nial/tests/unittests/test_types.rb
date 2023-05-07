# coding: utf-8
require "test/unit"
require_relative "../../source/lexer/lexer"
require_relative "../../source/parser/parser"
require_relative "../../source/interpreter/interpreter"
require_relative "../../source/scope/scope"
require_relative "../../source/position/position"

class Test_Types < Test::Unit::TestCase
  def evaluate_file(file, scope)
    data = File.read(file)    
    lexer = Lexer.new
    if (result = lexer.tokenize(data, nil)).is_a?(Error) then return result end
    parser = Parser.new(result)
    if (result = parser.parse).is_a?(Error) then return result end
    return Interpreter.evaluate(result, scope)
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

  def evaluate_variable_access(statement, scope)
    lexer = Lexer.new
    if (result = lexer.tokenize(statement, nil)).is_a?(Error) then return result end
    parser = Parser.new(result)
    if (result = parser.parse).is_a?(Error) then return result end
    result = Interpreter.evaluate_variable_access(result.statements[0], scope)
    return result
  end

  def evaluate_statements(statement, scope)
    lexer = Lexer.new
    if (result = lexer.tokenize(statement, nil)).is_a?(Error) then return result end
    parser = Parser.new(result)
    if (result = parser.parse).is_a?(Error) then return result end
    result = Interpreter.evaluate(result.statements[0], scope)
    return result
  end

  def test_single_type
    # Test a single type without inheritance or constructor parameters
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition1.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))
    
    result = evaluate_attribute_access("object@attribute", scope)
    assert_true(result.is_a?(Number))
    assert_equal(3, result.value)

    result = evaluate_method_call("call object.get_attribute()", scope)
    assert_true(result.is_a?(Number))
    assert_equal(3, result.value)

    result = evaluate_method_call("call object.set_attribute(5)", scope)

    result = evaluate_attribute_access("object@attribute", scope)
    assert_true(result.is_a?(Number))
    assert_equal(5, result.value)

    result = evaluate_method_call("call object.get_attribute()", scope)
    assert_true(result.is_a?(Number))
    assert_equal(5, result.value)
  end

  def test_type_with_constructor
    # Test a single type without inheritance with parameters passed to constructor
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition2.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))

    result = evaluate_attribute_access("object@first", scope)
    assert_true(result.is_a?(Number))
    assert_equal(3, result.value)

    result = evaluate_attribute_access("object@second", scope)
    assert_true(result.is_a?(Number))
    assert_equal(4, result.value)

    result = evaluate_method_call("call object.get_first()", scope)
    assert_true(result.is_a?(Number))
    assert_equal(3, result.value)

    result = evaluate_method_call("call object.set_first(5)", scope)
    assert_true(result.is_a?(Null))

    result = evaluate_attribute_access("object@first", scope)
    assert_true(result.is_a?(Number))
    assert_equal(5, result.value)

    result = evaluate_attribute_access("object@second", scope)
    assert_true(result.is_a?(Number))
    assert_equal(4, result.value)

    result = evaluate_method_call("call object.get_first()", scope)
    assert_true(result.is_a?(Number))
    assert_equal(5, result.value)
  end

  def test_call_method_within_method
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition3.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))

    result = evaluate_attribute_access("object@first", scope)
    assert_true(result.is_a?(Number))
    assert_equal(3, result.value)

    result = evaluate_method_call("call object.set_first(3)", scope)
    assert_true(result.is_a?(Null))

    result = evaluate_attribute_access("object@first", scope)
    assert_true(result.is_a?(Number))
    assert_equal(9, result.value)
  end

  def test_single_inheritence
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition4.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))

    result = evaluate_attribute_access("object@first", scope)
    assert_true(result.is_a?(Number))
    assert_equal(1, result.value)

    result = evaluate_attribute_access("object@second", scope)
    assert_true(result.is_a?(Number))
    assert_equal(2, result.value)

    result = evaluate_method_call("call object.basemethod()", scope)
    assert_true(result.is_a?(Text))
    assert_equal("FROM BASE", result.value)

    result = evaluate_method_call("call object.childmethod()", scope)
    assert_true(result.is_a?(Text))
    assert_equal("FROM CHILD", result.value)
  end

  def test_triple_inheritence
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition5.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))

    result = evaluate_attribute_access("object@first", scope)
    assert_true(result.is_a?(Number))
    assert_equal(1, result.value)

    result = evaluate_attribute_access("object@second", scope)
    assert_true(result.is_a?(Number))
    assert_equal(2, result.value)

    result = evaluate_attribute_access("object@third", scope)
    assert_true(result.is_a?(Number))
    assert_equal(3, result.value)

    result = evaluate_method_call("call object.basemethod()", scope)
    assert_true(result.is_a?(Text))
    assert_equal("OVERRIDE", result.value)

    result = evaluate_method_call("call object.set_first(4)", scope)
    assert_true(result.is_a?(Null))

    result = evaluate_attribute_access("object@first", scope)
    assert_true(result.is_a?(Number))
    assert_equal(4, result.value)
  end

  def test_operator_overloading
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition17.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))

    evaluate_statements('person = create Person(30, "Alex")', scope)
    result = evaluate_variable_access("person", scope)
    assert_true(result.is_a?(Type))
    evaluate_statements('sum = person + 10', scope)
    result = evaluate_variable_access("sum", scope)
    assert_true(result.is_a?(Number))
    assert_equal(40, result.value)

    evaluate_statements('name = person * 2', scope)
    result = evaluate_variable_access("name", scope)
    assert_true(result.is_a?(Text))
    assert_equal("AlexAlex", result.value)

    result = evaluate_statements('name = person / 2', scope)
    assert_true(result.is_a?(InvalidOperator))
  end

  def test_converting_to_list
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    # A type with the method convert_to_list defined
    result = evaluate_file(File.expand_path("../testfiles/typedefinition18.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))
    result = evaluate_variable_access("contents", scope)
    assert_equal(4, result.value.length)
    assert_equal(30, result.value[0].value)
    assert_equal(82, result.value[1].value)
    assert_equal(186, result.value[2].value)
    assert_equal(0, result.value[3].value)

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    # A type without method convert_to_list defined
    result = evaluate_file(File.expand_path("../testfiles/typedefinition19.nial", __FILE__), scope)
    assert_true(result.is_a?(ConversionError))
  end

  def test_constant_types
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    # A type with the method convert_to_list defined
    result = evaluate_file(File.expand_path("../testfiles/typedefinition20.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))
    result = evaluate_method_call("call normal.change()", scope)
    assert_false(result.is_a?(Error))
    result = evaluate_method_call("call CONSTANT.change()", scope)
    assert_true(result.is_a?(ConstantAlreadyDefined))
    
  end

  def test_exceptions
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition6.nial", __FILE__), scope)
    assert_true(result.is_a?(WrongNumberOfArguments))

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition7.nial", __FILE__), scope)
    assert_true(result.is_a?(WrongNumberOfArguments))

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition8.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))
    result = evaluate_method_call("call object.basemethod(3)", scope)
    assert_true(result.is_a?(WrongNumberOfArguments))

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition9.nial", __FILE__), scope)
    assert_false(result.is_a?(Error))

    result = evaluate_method_call("call object.test_method(66)", scope)
    assert_true(result.is_a?(Number))
    assert_equal(66, result.value)

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition10.nial", __FILE__), scope)
    assert_true(result.is_a?(DivisionByZero))

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition11.nial", __FILE__), scope)
    assert_true(result.is_a?(DivisionByZero))

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition12.nial", __FILE__), scope)
    assert_true(result.is_a?(TypeNotDefined))

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition13.nial", __FILE__), scope)
    assert_true(result.is_a?(TypeNotDefined))

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition14.nial", __FILE__), scope)
    assert_true(result.is_a?(UnexpectedTokenError))

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition15.nial", __FILE__), scope)
    assert_true(result.is_a?(UnexpectedTokenError))

    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = evaluate_file(File.expand_path("../testfiles/typedefinition16.nial", __FILE__), scope)
    assert_true(result.is_a?(UnexpectedTokenError)) 
  end
end
