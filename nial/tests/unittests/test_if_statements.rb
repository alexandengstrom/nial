require "test/unit"
require_relative "../../source/lexer/lexer"
require_relative "../../source/parser/parser"
require_relative "../../source/interpreter/interpreter"
require_relative "../../source/scope/scope"
require_relative "../../source/position/position"

class Test_If_Statement < Test::Unit::TestCase
  def evaluate(string)
    data = File.read(string)    
    lexer = Lexer.new
    if (result = lexer.tokenize(data, nil)).is_a?(Error) then return result end
    parser = Parser.new(result)
    if (result = parser.parse).is_a?(Error) then return result end
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = Interpreter.evaluate(result, scope)
    return result
  end

  def test_valid_if_statements
    result = evaluate(File.expand_path("../testfiles/ifstatement1.nial", __FILE__))
    assert_false(result.is_a?(Error))
  end

  def test_invalid_if_statements
    result = evaluate(File.expand_path("../testfiles/ifstatement2.nial", __FILE__))
    assert_true(result.is_a?(VariableNotDefined))

    result = evaluate(File.expand_path("../testfiles/ifstatement3.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    result = evaluate(File.expand_path("../testfiles/ifstatement4.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    result = evaluate(File.expand_path("../testfiles/ifstatement5.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    result = evaluate(File.expand_path("../testfiles/ifstatement6.nial", __FILE__))
    assert_true(result.is_a?(VariableNotDefined))

    result = evaluate(File.expand_path("../testfiles/ifstatement7.nial", __FILE__))
    assert_true(result.is_a?(UnexpectedTokenError))

    result = evaluate(File.expand_path("../testfiles/ifstatement8.nial", __FILE__))
    assert_true(result.is_a?(UnexpectedTokenError))

    result = evaluate(File.expand_path("../testfiles/ifstatement9.nial", __FILE__))
    assert_true(result.is_a?(UnexpectedTokenError))

    result = evaluate(File.expand_path("../testfiles/ifstatement10.nial", __FILE__))
    assert_true(result.is_a?(InvalidOperator))
    
    #result = evaluate(File.expand_path("../testfiles/ifstatement11.nial", __FILE__))
    #assert_true(result.is_a?(ConversionError))
  end
end
