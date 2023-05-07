require "test/unit"
require_relative "../../source/lexer/lexer"
require_relative "../../source/parser/parser"
require_relative "../../source/interpreter/interpreter"
require_relative "../../source/scope/scope"
require_relative "../../source/position/position"

class Test_Functions < Test::Unit::TestCase
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

  def test_valid_functions
    
    result = evaluate(File.expand_path("../testfiles/function1.nial", __FILE__))
    assert_false(result.is_a?(Error))
  end

  def test_invalid_functions
    result = evaluate(File.expand_path("../testfiles/function2.nial", __FILE__))
    assert_true(result.is_a?(VariableNotDefined))

    result = evaluate(File.expand_path("../testfiles/function3.nial", __FILE__))
    assert_true(result.is_a?(VariableNotDefined))

    result = evaluate(File.expand_path("../testfiles/function4.nial", __FILE__))
    assert_true(result.is_a?(WrongNumberOfArguments))
    
    result = evaluate(File.expand_path("../testfiles/function5.nial", __FILE__))
    assert_true(result.is_a?(WrongNumberOfArguments))

    result = evaluate(File.expand_path("../testfiles/function6.nial", __FILE__))
    assert_true(result.is_a?(WrongNumberOfArguments))

    result = evaluate(File.expand_path("../testfiles/function7.nial", __FILE__))
    assert_true(result.is_a?(UnexpectedTokenError))

    result = evaluate(File.expand_path("../testfiles/function8.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    result = evaluate(File.expand_path("../testfiles/function9.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    result = evaluate(File.expand_path("../testfiles/function10.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    #result = evaluate(File.expand_path("../testfiles/function11.nial", __FILE__))
    #assert_true(result.is_a?(ConversionError))

    result = evaluate(File.expand_path("../testfiles/function12.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    result = evaluate(File.expand_path("../testfiles/function13.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))
  end

end
