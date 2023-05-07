require "test/unit"
require_relative "../../source/datatypes/number"
require_relative "../../source/datatypes/text"
require_relative "../../source/datatypes/boolean"
require_relative "../../source/datatypes/function"
require_relative "../../source/scope/scope"
require_relative "../../source/interpreter/interpreter"
require_relative "../../source/lexer/lexer"
require_relative "../../source/parser/parser"
require_relative "../../source/position/position"

class Test_Interpreter < Test::Unit::TestCase
  def evaluate_statement(string, scope=nil)
    lexer = Lexer.new
    parser = Parser.new(lexer.tokenize(string))
    result = parser.parse_statement
    if !scope
      scope = Scope.new("global", nil, Position.new(1,1,1))
    end
    result = Interpreter.evaluate(result, scope)
    return result
  end

  
  def test_arithmetic_expression
    result = evaluate_statement("1+1")  
    assert_equal(Number, result.class)
    assert_equal(2, result.value)

    result = evaluate_statement("1+2*5")  
    assert_equal(Number, result.class)
    assert_equal(11, result.value)

    result = evaluate_statement("(1+2)*5")  
    assert_equal(Number, result.class)
    assert_equal(15, result.value)

    result = evaluate_statement("(1-2)*5")  
    assert_equal(Number, result.class)
    assert_equal(-5, result.value)

    result = evaluate_statement("(5*5/5)")  
    assert_equal(Number, result.class)
    assert_equal(5, result.value)

    result = evaluate_statement("2+2+2+2+2")  
    assert_equal(Number, result.class)
    assert_equal(10, result.value)

    result = evaluate_statement("-1*2+2+2+2+2")  
    assert_equal(Number, result.class)
    assert_equal(6, result.value)

    result = evaluate_statement("-1*(2+2+2+2+2)")  
    assert_equal(Number, result.class)
    assert_equal(-10, result.value)

    result = evaluate_statement("-1*-1")  
    assert_equal(Number, result.class)
    assert_equal(1, result.value)

    result = evaluate_statement("3%2*5")  
    assert_equal(Number, result.class)
    assert_equal(5, result.value)

    result = evaluate_statement("0-15+21")  
    assert_equal(Number, result.class)
    assert_equal(6, result.value)

    result = evaluate_statement("10%2*2")  
    assert_equal(Number, result.class)
    assert_equal(0, result.value)

    result = evaluate_statement("8/4/2")  
    assert_equal(Number, result.class)
    assert_equal(1, result.value)

    result = evaluate_statement('"hello" + " world"')  
    assert_equal(Text, result.class)
    assert_equal("hello world", result.value)

    result = evaluate_statement('"a" + "longer" + "string"')  
    assert_equal(Text, result.class)
    assert_equal("alongerstring", result.value)

    result = evaluate_statement('"hello" * 3')  
    assert_equal(Text, result.class)
    assert_equal("hellohellohello", result.value)

    result = evaluate_statement('2 * "hello"')  
    assert_equal(Text, result.class)
    assert_equal("hellohello", result.value)

    result = evaluate_statement('-1 * "hello"')  
    assert_equal(InvalidOperator, result.class)
  end

  def test_greater_than
    result = evaluate_statement("2>1")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("2>2")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("2>3")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("2>-3")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("-2>1")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("1000000000>100000000")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)
  end

  def test_less_than
    result = evaluate_statement("2<1")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("2<2")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("2<3")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("2<-3")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("-2<1")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("-2300000000<-100000000")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)
  end

  def test_equals
    result = evaluate_statement("2==2")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)
    
    result = evaluate_statement("-2==-2")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("2==-2")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("-2==2")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("1000000000==1000000000")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement('"" == 0')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('"" == "0"')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('"text" == 0')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('"text" == -1')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('True == False')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('False == True')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('True == True')  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement('False == False')  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)
  end

  def test_not_equals
    result = evaluate_statement("2!=2")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)
    
    result = evaluate_statement("-2!=-2")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("2!=-2")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("-2!=2")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("1000000000!=1000000000")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('"" != 0')  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement('"" != "0"')  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement('"text" != 0')  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement('"text" != -1')  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement('True != False')  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement('False != True')  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement('True != True')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('False != False')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)
  end

  def test_equals_or_greater_than
    result = evaluate_statement("10 >= 10")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("10 >= 11")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("11 >= 10")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("-10 >= 10")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("-10 >= -10")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("1 >= -10")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("-1000 >= -200")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)
  end

  def equals_or_less_than
    result = evaluate_statement("10 <= 10")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("10 <= 11")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("11 <= 10")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("-10 <= 10")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("-10 <= -10")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("1 <= -10")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("-1000 <= -200")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)
  end

  def test_and
    result = evaluate_statement("2>1 and -200<0")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("2>1 and -200<0 and 10!=9 and 2==2")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("2>1 and -200<0 and 10!=9 and 2==1")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("True and True")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("False and False")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("True and False")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("False and True")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)
  end

  def test_or
    result = evaluate_statement("2>1 or -200<0")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("2>1 or -200<0 or 10!=9 or 2==2")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("2>1 or -200<0 or 10!=9 or 2==1")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("2<1 or -200>0 or 10==9 or 2==1")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("True or True")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("False or False")  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement("True or False")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement("False or True")  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)
  end

  def test_number_methods
    result = evaluate_statement("call 9.square_root()")  
    assert_equal(Number, result.class)
    assert_equal(3, result.value)

    result = evaluate_statement("call 100.square_root()")  
    assert_equal(Number, result.class)
    assert_equal(10, result.value)

    result = evaluate_statement("call 0.square_root()")  
    assert_equal(Number, result.class)
    assert_equal(0, result.value)

    result = evaluate_statement("call -1.square_root()")  
    assert_equal(InvalidOperator, result.class)

    result = evaluate_statement("call 3.factorial()")  
    assert_equal(Number, result.class)
    assert_equal(6, result.value)

    result = evaluate_statement("call 5.factorial()")  
    assert_equal(Number, result.class)
    assert_equal(120, result.value)

    result = evaluate_statement("call 0.factorial()")  
    assert_equal(Number, result.class)
    assert_equal(1, result.value)

    result = evaluate_statement("call -3.factorial()")  
    assert_equal(InvalidOperator, result.class)

    result = evaluate_statement("call 3.1415.round(2)")  
    assert_equal(Number, result.class)
    assert_equal(3.14, result.value)

    result = evaluate_statement("call 3.1415.round(0)")  
    assert_equal(Number, result.class)
    assert_equal(3, result.value)

    result = evaluate_statement("call 3.1415.round(-1)")  
    assert_equal(Number, result.class)
    assert_equal(0, result.value)

    result = evaluate_statement("call 3.absolute_value()")  
    assert_equal(Number, result.class)
    assert_equal(3, result.value)

    result = evaluate_statement("call -3.absolute_value()")  
    assert_equal(Number, result.class)
    assert_equal(3, result.value)
  end

  def test_text_methods
    result = evaluate_statement('call "hello world".length()')  
    assert_equal(Number, result.class)
    assert_equal(11, result.value)

    result = evaluate_statement('call "".length()')  
    assert_equal(Number, result.class)
    assert_equal(0, result.value)

    result = evaluate_statement('call "123".length()')  
    assert_equal(Number, result.class)
    assert_equal(3, result.value)

    result = evaluate_statement('call "123".convert_to_number()')  
    assert_equal(Number, result.class)
    assert_equal(123, result.value)

    result = evaluate_statement('call "0".convert_to_number()')  
    assert_equal(Number, result.class)
    assert_equal(0, result.value)

    result = evaluate_statement('call "1.1".convert_to_number()')  
    assert_equal(Number, result.class)
    assert_equal(1.1, result.value)

    result = evaluate_statement('call "hello world".upper()')  
    assert_equal(Text, result.class)
    assert_equal("HELLO WORLD", result.value)

    result = evaluate_statement('call "".upper()')  
    assert_equal(Text, result.class)
    assert_equal("", result.value)

    result = evaluate_statement('call "123".upper()')  
    assert_equal(Text, result.class)
    assert_equal("123", result.value)

    result = evaluate_statement('call "HELLO WORLD".lower()')  
    assert_equal(Text, result.class)
    assert_equal("hello world", result.value)

    result = evaluate_statement('call "".lower()')  
    assert_equal(Text, result.class)
    assert_equal("", result.value)

    result = evaluate_statement('call "123".lower()')  
    assert_equal(Text, result.class)
    assert_equal("123", result.value)

    result = evaluate_statement('call "hello world".strip()')  
    assert_equal(Text, result.class)
    assert_equal("hello world", result.value)

    result = evaluate_statement('call "     hello world".strip()')  
    assert_equal(Text, result.class)
    assert_equal("hello world", result.value)

    result = evaluate_statement('call "hello world      ".strip()')  
    assert_equal(Text, result.class)
    assert_equal("hello world", result.value)

    result = evaluate_statement('call "     hello world  ".strip()')  
    assert_equal(Text, result.class)
    assert_equal("hello world", result.value)

    result = evaluate_statement('call "test".left_justify(10)')  
    assert_equal(Text, result.class)
    assert_equal("test      ", result.value)

    result = evaluate_statement('call "test".right_justify(10)')  
    assert_equal(Text, result.class)
    assert_equal("      test", result.value)

    result = evaluate_statement('call "test".right_justify("10")')  
    assert_equal(Text, result.class)
    assert_equal("      test", result.value)

    result = evaluate_statement('call "test".right_justify(True)')  
    assert_equal(Text, result.class)

    result = evaluate_statement('call "test".right_justify(Null)')  
    assert_equal(ConversionError, result.class)

    result = evaluate_statement('call "test".right_justify([1, 2, 3])')  
    assert_equal(ConversionError, result.class)

    result = evaluate_statement('call "hello world".sub("hello", "hi")')  
    assert_equal(Text, result.class)
    assert_equal("hi world", result.value)

    # Should try to convert 2 to a text
    result = evaluate_statement('call "hello world".sub(2, "hi")')  
    assert_equal(Text, result.class)
    assert_equal("hello world", result.value)

    result = evaluate_statement('call "hello world".sub("hello", [1,2,3])')  
    assert_equal(ConversionError, result.class)

    result = evaluate_statement('call "this is a sentence
over multiple
lines".split_lines()')  
    assert_equal(List, result.class)
    assert_equal(3, result.value.length)

    result = evaluate_statement('call "a sentence on one line".split_lines()')  
    assert_equal(List, result.class)
    assert_equal(1, result.value.length)

    result = evaluate_statement('call "a sentence on one line".split_words()')  
    assert_equal(List, result.class)
    assert_equal(5, result.value.length)

    result = evaluate_statement('call "word".split_lines()')  
    assert_equal(List, result.class)
    assert_equal(1, result.value.length)

    result = evaluate_statement('call "an ok sentence ok with ok many ok".split("ok")')  
    assert_equal(List, result.class)
    assert_equal(4, result.value.length)

    # Should try to convert the number into text
    result = evaluate_statement('call "an ok sentence ok with ok many ok".split(1)')  
    assert_equal(List, result.class)
    assert_equal(1, result.value.length)
  end

  def test_list_methods
    result = evaluate_statement('call [1, 2, 3, 4].pop()')  
    assert_equal(Number, result.class)
    assert_equal(4, result.value)

    result = evaluate_statement('call [1, 2, 3, "test"].pop()')  
    assert_equal(Text, result.class)
    assert_equal("test", result.value)

    result = evaluate_statement('call [].pop()')  
    assert_equal(Null, result.class)

    result = evaluate_statement('call [1, 2, 3, 4].has_value(4)')  
    assert_equal(Boolean, result.class)
    assert_equal(true, result.value)

    result = evaluate_statement('call [1, 2, 3, 4].has_value("4")')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('call [1, 2, 3, 4].has_value(0)')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('call [1, 2, 3, 4].has_value(-1)')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('call [1, 2, 3, 4].has_value(1.1)')  
    assert_equal(Boolean, result.class)
    assert_equal(false, result.value)

    result = evaluate_statement('call [1, 2, 3, 4].first()')  
    assert_equal(Number, result.class)
    assert_equal(1, result.value)

    result = evaluate_statement('call [1, 2, 3, 4].last()')  
    assert_equal(Number, result.class)
    assert_equal(4, result.value)

    result = evaluate_statement('call [1, 2, 3, 4].join(" ")')  
    assert_equal(Text, result.class)
    assert_equal("1 2 3 4", result.value)

    result = evaluate_statement('call [1, 2, 3, 4].join("ok")')  
    assert_equal(Text, result.class)
    assert_equal("1ok2ok3ok4", result.value)

    result = evaluate_statement('call [1].join("ok")')  
    assert_equal(Text, result.class)
    assert_equal("1", result.value)

    result = evaluate_statement('call [].join("ok")')  
    assert_equal(Text, result.class)
    assert_equal("", result.value)
  end

  def test_exceptions
    result = evaluate_statement("2/0")
    assert_equal(DivisionByZero, result.class)

    result = evaluate_statement("2/(2-2)")
    assert_equal(DivisionByZero, result.class)

    result = evaluate_statement("x + 2")
    assert_equal(VariableNotDefined, result.class)
  end

  def test_randopmanager
    50.times do
      result = evaluate_statement('call RandOpManager.get_integer(0, 10)')  
      assert_equal(Number, result.class)
      assert_true(result.value >= 0 && result.value <= 10)
    end

    10.times do
      result = evaluate_statement('call RandOpManager.get_integer(0, 1)')  
      assert_true(result.value >= 0 && result.value <= 1)
    end

    10.times do
      result = evaluate_statement('call RandOpManager.get_integer(-10, -1)')  
      assert_true(result.value >= -10 && result.value <= -1)
    end

    20.times do
      result = evaluate_statement('call RandOpManager.pick_item([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])')  
      assert_equal(Number, result.class)
      assert_true(result.value >= 0 && result.value <= 10)
    end

    result = evaluate_statement('call RandOpManager.pick_item([])')  
    assert_equal(Null, result.class)
  end

  def test_algomanager
    scope = Scope.new("global", nil, Position.new(1,1,1))
    evaluate_statement("list = [3,6,2,8,10,9,20,3,14, 0]", scope)
    result = evaluate_statement("call AlgoManager.mergesort(list, |a,b|a<b|)", scope)
    assert_true(result.is_a?(List))
    temp_value = -1
    result.value.each {|v|
      assert_true(v.value >= temp_value)
      temp_value = v.value
    }

    result = evaluate_statement("call AlgoManager.bubblesort(list, |a,b|a<b|)", scope)
    assert_true(result.is_a?(List))
    temp_value = -1
    result.value.each {|v|
      assert_true(v.value >= temp_value)
      temp_value = v.value
    }

    result = evaluate_statement("call AlgoManager.quicksort(list, |a,b|a<b|)", scope)
    assert_true(result.is_a?(List))
    temp_value = -1
    result.value.each {|v|
      assert_true(v.value >= temp_value)
      temp_value = v.value
    }

    result = evaluate_statement("call AlgoManager.filter(list, |a|a%2==0|)", scope)
    assert_true(result.is_a?(List))
    assert_equal(7, result.value.length)
    result.value.each {|v|
      assert_true(v.value % 2 == 0)
    }
  end
end
