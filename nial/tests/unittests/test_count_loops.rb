require "test/unit"
require_relative "../../source/lexer/lexer"
require_relative "../../source/parser/parser"
require_relative "../../source/interpreter/interpreter"
require_relative "../../source/scope/scope"
require_relative "../../source/position/position"

class Test_Count_Loop_Statement < Test::Unit::TestCase
  def evaluate(string)
    data = File.read(string)    
    lexer = Lexer.new
    if (result = lexer.tokenize(data)).is_a?(Error) then return result end
    parser = Parser.new(result)
    if (result = parser.parse).is_a?(Error) then return result end
    position = Position.new(1,1,1)
    scope = Scope.new("global", nil, position)
    result = Interpreter.evaluate(result, scope)
    return result
  end

  def test_valid_loops
    result = evaluate(File.expand_path("../testfiles/countloop1.nial", __FILE__))
    assert_false(result.is_a?(Error))
  end

  def test_invalid_loops
    result = evaluate(File.expand_path("../testfiles/countloop2.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    result = evaluate(File.expand_path("../testfiles/countloop3.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    result = evaluate(File.expand_path("../testfiles/countloop4.nial", __FILE__))
    assert_true(result.is_a?(DivisionByZero))

    result = evaluate(File.expand_path("../testfiles/countloop5.nial", __FILE__))
    assert_true(result.is_a?(VariableNotDefined))

    result = evaluate(File.expand_path("../testfiles/countloop6.nial", __FILE__))
    assert_true(result.is_a?(VariableNotDefined))

    result = evaluate(File.expand_path("../testfiles/countloop7.nial", __FILE__))
    assert_true(result.is_a?(UnexpectedTokenError))

    result = evaluate(File.expand_path("../testfiles/countloop8.nial", __FILE__))
    assert_true(result.is_a?(UnexpectedTokenError))

    result = evaluate(File.expand_path("../testfiles/countloop9.nial", __FILE__))
    assert_true(result.is_a?(ConversionError))

    result = evaluate(File.expand_path("../testfiles/countloop10.nial", __FILE__))
    assert_true(result.is_a?(NextError))
  end
  
end
