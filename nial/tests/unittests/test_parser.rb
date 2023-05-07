require "test/unit"
require_relative "../../source/lexer/lexer"
require_relative "../../source/parser/parser"

class Test_Parser < Test::Unit::TestCase
  def test_arithmetic_expression
    lexer = Lexer.new

    # Test addition
    parser = Parser.new(lexer.tokenize('2+2'))
    result = parser.parse_statement



    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(NumericNode))
    assert_equal(2, result.left_node.value)
    assert_true(result.right_node.is_a?(NumericNode))
    assert_equal(2, result.right_node.value)
    assert_true(result.operator.type == :ADDITION)

    # Test addition and division combined
    parser = Parser.new(lexer.tokenize('2+5/1'))
    result = parser.parse_statement

    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(NumericNode))
    assert_equal(2, result.left_node.value)
    assert_true(result.right_node.is_a?(BinaryOperationNode))
    assert_true(result.operator.type == :ADDITION)
    assert_true(result.right_node.operator.type == :DIVISION)
    assert_true(result.right_node.right_node.is_a?(NumericNode))
    assert_equal(5, result.right_node.left_node.value)
    assert_true(result.right_node.left_node.is_a?(NumericNode))
    assert_equal(1, result.right_node.right_node.value)

    # Test parenteses
    parser = Parser.new(lexer.tokenize('5*(1+1)'))
    result = parser.parse_statement
    
    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(NumericNode))
    assert_equal(5, result.left_node.value)
    assert_true(result.right_node.is_a?(BinaryOperationNode))
    assert_true(result.operator.type == :MULTIPLICATION)
    assert_true(result.right_node.operator.type == :ADDITION)
    assert_true(result.right_node.right_node.is_a?(NumericNode))
    assert_equal(1, result.right_node.left_node.value)
    assert_true(result.right_node.left_node.is_a?(NumericNode))
    assert_equal(1, result.right_node.right_node.value)

    # Test long expressions
    parser = Parser.new(lexer.tokenize('1-2*(2+2)+6'))
    result = parser.parse_statement
    
    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.right_node.is_a?(NumericNode))
    assert_equal(6, result.right_node.value)
    assert_true(result.left_node.is_a?(BinaryOperationNode))
    assert_true(result.operator.type == :ADDITION)
    assert_true(result.left_node.operator.type == :SUBTRACTION)
    assert_true(result.left_node.right_node.is_a?(BinaryOperationNode))
    assert_true(result.left_node.left_node.is_a?(NumericNode))
    result = result.left_node.right_node 
    assert_true(result.left_node.is_a?(NumericNode))
    assert_true(result.right_node.is_a?(BinaryOperationNode))
    assert_true(result.operator.type == :MULTIPLICATION)
    assert_true(result.right_node.left_node.is_a?(NumericNode))
    assert_true(result.right_node.right_node.is_a?(NumericNode))
    assert_true(result.right_node.operator.type == :ADDITION)

    # Test exceptions
    parser = Parser.new(lexer.tokenize('1+2 2'))
    result = parser.parse
        
    assert_true(result.is_a?(UnexpectedTokenError))

    parser = Parser.new(lexer.tokenize('1(2+2)'))
    result = parser.parse
        
    assert_true(result.is_a?(UnexpectedTokenError))
    
  end

  def test_comparison_expression
    lexer = Lexer.new

    # Test equals to
    parser = Parser.new(lexer.tokenize('2==2'))
    result = parser.parse_statement

    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(NumericNode))
    assert_equal(2, result.left_node.value)
    assert_true(result.right_node.is_a?(NumericNode))
    assert_equal(2, result.right_node.value)
    assert_true(result.operator.type == :EQUALS)

    # Test greather than combined with arithmetics
    parser = Parser.new(lexer.tokenize('2+2>2'))
    result = parser.parse_statement

    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(BinaryOperationNode))
    assert_true(result.right_node.is_a?(NumericNode))
    assert_equal(2, result.right_node.value)
    assert_true(result.operator.type == :GREATER_THAN)
    assert_true(result.left_node.left_node.is_a?(NumericNode))
    assert_true(result.left_node.right_node.is_a?(NumericNode))
    assert_true(result.left_node.operator.type == :ADDITION)

    # Test that True and False can be converted to booleans
    parser = Parser.new(lexer.tokenize('True or False'))
    result = parser.parse_statement

    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(BooleanNode))
    assert_true(result.right_node.is_a?(BooleanNode))
    assert_equal(:OR, result.operator.type)

    # Test null
    parser = Parser.new(lexer.tokenize('Null'))
    result = parser.parse_statement

    assert_true(result.is_a?(NullNode))

    # Test exceptions

    parser = Parser.new(lexer.tokenize('1<2==2)'))
    result = parser.parse
        
    assert_true(result.is_a?(UnexpectedTokenError))
  end

  def test_logical_expression
    lexer = Lexer.new

    # Test and
    parser = Parser.new(lexer.tokenize('2>1 and 4<6'))
    result = parser.parse_statement

    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(BinaryOperationNode))
    assert_true(result.right_node.is_a?(BinaryOperationNode))
    assert_true(result.operator.type == :AND)

    # Test or
    parser = Parser.new(lexer.tokenize('2>1 or 4<6'))
    result = parser.parse_statement

    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(BinaryOperationNode))
    assert_true(result.right_node.is_a?(BinaryOperationNode))
    assert_true(result.operator.type == :OR)

    # Test chaining
    parser = Parser.new(lexer.tokenize('2>1 or 4<6 and 4==2'))
    result = parser.parse_statement

    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(BinaryOperationNode))
    assert_true(result.left_node.operator.type == :OR)
    assert_true(result.right_node.is_a?(BinaryOperationNode))
    assert_true(result.operator.type == :AND)

    # Test exceptions
    parser = Parser.new(lexer.tokenize('and 2>3'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))

    parser = Parser.new(lexer.tokenize('or 2>3'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))

    parser = Parser.new(lexer.tokenize('or 2>3 and 4!=2'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))
    
  end

  def test_variable_assignment
    lexer = Lexer.new

    # Test assigning a number to an variable
    parser = Parser.new(lexer.tokenize('x = 50'))
    result = parser.parse_statement

    assert_true(result.is_a?(VariableAssignmentNode))
    assert_true(result.value.is_a?(NumericNode))
    assert_true(result.identifier.value == "x")

    # Test assigning text to an variable
    parser = Parser.new(lexer.tokenize('y = "hello world"'))
    result = parser.parse_statement

    assert_true(result.is_a?(VariableAssignmentNode))
    assert_true(result.value.is_a?(TextNode))
    assert_true(result.identifier.value == "y")

    # Test assigning an expression to an variable
    parser = Parser.new(lexer.tokenize('x = 52*4+2/2'))
    result = parser.parse_statement

    assert_true(result.is_a?(VariableAssignmentNode))
    assert_true(result.value.is_a?(BinaryOperationNode))
    assert_true(result.identifier.value == "x")

    # Test assigning an logical expression to an variable
    parser = Parser.new(lexer.tokenize('x = 1 > 2'))
    result = parser.parse_statement

    assert_true(result.is_a?(VariableAssignmentNode))
    assert_true(result.value.is_a?(BinaryOperationNode))
    assert_true(result.identifier.value == "x")

    # Test using invalid identifier names
    parser = Parser.new(lexer.tokenize('if = 1 > 2'))
    result = parser.parse_statement

    assert_true(result.is_a?(UnexpectedTokenError))

    # Test assigning invalid expression
    parser = Parser.new(lexer.tokenize('x = 1 2'))
    result = parser.parse

    assert_true(result.is_a?(UnexpectedTokenError))
  end

  def test_variable_access
    lexer = Lexer.new

    # Test accessing variable
    parser = Parser.new(lexer.tokenize('x'))
    result = parser.parse_statement

    assert_true(result.is_a?(VariableAccessNode))
    assert_true(result.identifier.value == "x")

    # Test accessing variable inside expression
    parser = Parser.new(lexer.tokenize('x+2'))
    result = parser.parse_statement

    assert_true(result.is_a?(BinaryOperationNode))
    assert_true(result.left_node.is_a?(VariableAccessNode))
    assert_true(result.right_node.is_a?(NumericNode)) 
  end

  def test_if_statement
    lexer = Lexer.new

    # Test oneline if-statement
    parser = Parser.new(lexer.tokenize('if x > 2 then x = 2 stop'))
    result = parser.parse_statement

    assert_true(result.is_a?(IfStatementNode))
    assert_true(result.branches[0].is_a?(IfBranchNode))
    assert_true(result.branches[0].condition.is_a?(BinaryOperationNode))
    assert_true(result.branches[0].block.is_a?(StatementsNode))

    # Test single if statement
    parser = Parser.new(lexer.tokenize('if x > 2 then 
    x = 2 
stop'))
    result = parser.parse_statement

    assert_true(result.is_a?(IfStatementNode))
    assert_true(result.branches[0].is_a?(IfBranchNode))
    assert_true(result.branches[0].condition.is_a?(BinaryOperationNode))
    assert_true(result.branches[0].block.is_a?(StatementsNode))

    # Test if-statement without elifs but with else
    parser = Parser.new(lexer.tokenize('if x > 2 then 
    x = 2
else
    x = 4 
stop'))
    result = parser.parse_statement

    assert_true(result.is_a?(IfStatementNode))
    assert_true(result.branches[0].is_a?(IfBranchNode))
    assert_true(result.branches[0].condition.is_a?(BinaryOperationNode))
    assert_true(result.branches[0].block.is_a?(StatementsNode))

    assert_true(result.else_block.is_a?(StatementsNode))

    # Test if statement with many branches
    parser = Parser.new(lexer.tokenize('if x > 2 then x = 2 
else if x < 2 then x = 3 
else if x > 40 then x = "hello world" 
else x = 49 
stop'))
    
    result = parser.parse_statement

    assert_true(result.is_a?(IfStatementNode))
    assert_true(result.branches[0].is_a?(IfBranchNode))
    assert_true(result.branches[0].condition.is_a?(BinaryOperationNode))
    assert_true(result.branches[0].block.is_a?(StatementsNode))
    assert_true(result.branches[1].is_a?(IfBranchNode))
    assert_true(result.branches[1].condition.is_a?(BinaryOperationNode))
    assert_true(result.branches[1].block.is_a?(StatementsNode))
    assert_true(result.branches[2].is_a?(IfBranchNode))
    assert_true(result.branches[2].condition.is_a?(BinaryOperationNode))
    assert_true(result.branches[2].block.is_a?(StatementsNode))
    assert_true(result.else_block.is_a?(StatementsNode))

    # Test exceptions
    parser = Parser.new(lexer.tokenize('if x > 2 then x = 2 
else y = 2
else x = 49 
stop'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))

    parser = Parser.new(lexer.tokenize('if x > 2 x = 2 
else y = 2
stop'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))
  end

  def test_function_definition
    lexer = Lexer.new

    # Test function definition without parameters
    parser = Parser.new(lexer.tokenize('define function func() 
    x = 2 
stop'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionDefinitionNode))
    assert_true(result.parameters.empty?)
    assert_true(result.block.is_a?(StatementsNode))
    assert_true(result.block.statements[0].is_a?(VariableAssignmentNode))
    assert_equal("func", result.name.value)

    # Test function definition with one parameter
    parser = Parser.new(lexer.tokenize('define function func(parameter) 
       x = 2 
stop
'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionDefinitionNode))
    assert_equal(1, result.parameters.length)
    assert_equal("parameter", result.parameters[0][0].value)
    assert_true(result.block.is_a?(StatementsNode))
    assert_true(result.block.statements[0].is_a?(VariableAssignmentNode))
    assert_equal("func", result.name.value)

    # Test function definition with multiple parameters
    parser = Parser.new(lexer.tokenize('define function func(parameter1, parameter2, parameter3) 
       2+2 
stop
'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionDefinitionNode))
    assert_equal(3, result.parameters.length)
    assert_equal("parameter1", result.parameters[0][0].value)
    assert_equal("parameter2", result.parameters[1][0].value)
    assert_equal("parameter3", result.parameters[2][0].value)
    assert_true(result.block.is_a?(StatementsNode))
    assert_true(result.block.statements[0].is_a?(BinaryOperationNode))
    assert_equal("func", result.name.value)

    # Test exceptions
    parser = Parser.new(lexer.tokenize('define function func(parameters without comma) 
    x = 2 
stop'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))

    # Test forgetting stop
    parser = Parser.new(lexer.tokenize('define function func() 
    x = 2'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))
  end

  def test_lambda
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('| x | x > 2 |'))
    result = parser.parse_statement
    assert_true(result.is_a?(FunctionDefinitionNode))
    assert_equal(1, result.parameters.length)
    assert_equal("x", result.parameters[0][0].value)

    parser = Parser.new(lexer.tokenize('| x, y, z | x > 2 |'))
    result = parser.parse_statement
    assert_true(result.is_a?(FunctionDefinitionNode))
    assert_equal(3, result.parameters.length)
    assert_equal("x", result.parameters[0][0].value)
    assert_equal("y", result.parameters[1][0].value)
    assert_equal("z", result.parameters[2][0].value)
  end
  
  def test_function_call
    lexer = Lexer.new

    # Call function without parameters
    parser = Parser.new(lexer.tokenize('call func()'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionCallNode))
    assert_true(result.arguments.empty?)

    # Call function with one identifier as parameter
    parser = Parser.new(lexer.tokenize('call func(identifier)'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionCallNode))
    assert_equal(1, result.arguments.length)
    assert_true(result.arguments[0].is_a?(VariableAccessNode))

    # Call function with one number as parameter
    parser = Parser.new(lexer.tokenize('call func(2)'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionCallNode))
    assert_equal(1, result.arguments.length)
    assert_true(result.arguments[0].is_a?(NumericNode))

    # Call function with one string as parameter
    parser = Parser.new(lexer.tokenize('call func("hello world")'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionCallNode))
    assert_equal(1, result.arguments.length)
    assert_true(result.arguments[0].is_a?(TextNode))

    # Call function with one expression as parameter
    parser = Parser.new(lexer.tokenize('call func(3+3/4)'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionCallNode))
    assert_equal(1, result.arguments.length)
    assert_true(result.arguments[0].is_a?(BinaryOperationNode))

    # Call function with multiple numbers as parameters
    parser = Parser.new(lexer.tokenize('call func(3, 4, 6, 7)'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionCallNode))
    assert_equal(4, result.arguments.length)
    assert_true(result.arguments[0].is_a?(NumericNode))
    assert_true(result.arguments[1].is_a?(NumericNode))
    assert_true(result.arguments[2].is_a?(NumericNode))
    assert_true(result.arguments[3].is_a?(NumericNode))

    # Call function with multiple parameters of different types
    parser = Parser.new(lexer.tokenize('call func(3+2/2, "hello", 3, varname)'))
    result = parser.parse_statement

    assert_true(result.is_a?(FunctionCallNode))
    assert_equal(4, result.arguments.length)
    assert_true(result.arguments[0].is_a?(BinaryOperationNode))
    assert_true(result.arguments[1].is_a?(TextNode))
    assert_true(result.arguments[2].is_a?(NumericNode))
    assert_true(result.arguments[3].is_a?(VariableAccessNode))

    # Call lambda
    parser = Parser.new(lexer.tokenize('call | x, y, z | x > 2 |(1, 2, 3)'))
    result = parser.parse_statement
    assert_true(result.is_a?(FunctionCallNode))
    assert_equal(3, result.arguments.length)
  end

  def test_display
    lexer = Lexer.new

    # Display number
    parser = Parser.new(lexer.tokenize('display 3'))
    result = parser.parse_statement

    assert_true(result.is_a?(DisplayNode))
    assert_true(result.value_node.is_a?(NumericNode))

    # Display text
    parser = Parser.new(lexer.tokenize('display "hello"'))
    result = parser.parse_statement

    assert_true(result.is_a?(DisplayNode))
    assert_true(result.value_node.is_a?(TextNode))

    # Display expression
    parser = Parser.new(lexer.tokenize('display 35*35'))
    result = parser.parse_statement

    assert_true(result.is_a?(DisplayNode))
    assert_true(result.value_node.is_a?(BinaryOperationNode))
  end

  def test_user_input
    lexer = Lexer.new

    # Get user input
    parser = Parser.new(lexer.tokenize('let user assign x'))
    result = parser.parse_statement

    assert_true(result.is_a?(UserInputNode))
  end

  def test_return
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('return
'))
    result = parser.parse_statement
    assert_true(result.is_a?(ReturnNode))

    parser = Parser.new(lexer.tokenize('return 2*2'))
    result = parser.parse_statement
    assert_true(result.is_a?(ReturnNode))
    assert_true(result.return_value.is_a?(BinaryOperationNode))
    assert_true(result.return_value.left_node.is_a?(NumericNode))
    assert_true(result.return_value.right_node.is_a?(NumericNode))
    assert_true(result.return_value.operator.type == :MULTIPLICATION)
  end

  def test_count_loop
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('
count x from 1 to 10
display x
stop'))
    result = parser.parse_statements
    assert_equal(CountLoopNode, result.statements[0].class)
    assert_true(result.statements[0].from.is_a?(NumericNode))
    assert_true(result.statements[0].to.is_a?(NumericNode))

    parser = Parser.new(lexer.tokenize('
count x from -1 to 1+1
display x
stop'))
    result = parser.parse_statements
    assert_equal(CountLoopNode, result.statements[0].class)
    assert_true(result.statements[0].from.is_a?(UnaryOperationNode))
    assert_true(result.statements[0].to.is_a?(BinaryOperationNode))

    parser = Parser.new(lexer.tokenize('
count x from 1 to 10
display x'))
    result = parser.parse_statements
    assert_equal(UnexpectedTokenError, result.class)

    parser = Parser.new(lexer.tokenize('
count x from 1 to
display x
stop'))
    result = parser.parse_statements
    assert_equal(UnexpectedTokenError, result.class)
  end

  def test_lists
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('[]'))
    result = parser.parse_statement
    assert_true(result.is_a?(ListNode))
    assert_equal(0, result.parameters.length)

    parser = Parser.new(lexer.tokenize('[1]'))
    result = parser.parse_statement
    assert_true(result.is_a?(ListNode))
    assert_equal(1, result.parameters.length)
    assert_true(result.parameters[0].is_a?(NumericNode))


    parser = Parser.new(lexer.tokenize('[1, 2]'))
    result = parser.parse_statement
    assert_true(result.is_a?(ListNode))
    assert_equal(2, result.parameters.length)
    assert_true(result.parameters[0].is_a?(NumericNode))
    assert_true(result.parameters[1].is_a?(NumericNode))

    parser = Parser.new(lexer.tokenize('[1+2]'))
    result = parser.parse_statement
    assert_true(result.is_a?(ListNode))
    assert_equal(1, result.parameters.length)
    assert_true(result.parameters[0].is_a?(BinaryOperationNode))
    assert_true(result.parameters[0].left_node.is_a?(NumericNode))
    assert_true(result.parameters[0].right_node.is_a?(NumericNode))

    parser = Parser.new(lexer.tokenize('[1+2, var, "hello world"]'))
    result = parser.parse_statement
    assert_true(result.is_a?(ListNode))
    assert_equal(3, result.parameters.length)
    assert_true(result.parameters[0].is_a?(BinaryOperationNode))
    assert_true(result.parameters[0].left_node.is_a?(NumericNode))
    assert_true(result.parameters[0].right_node.is_a?(NumericNode))
    assert_true(result.parameters[1].is_a?(VariableAccessNode))
    assert_true(result.parameters[2].is_a?(TextNode))

    parser = Parser.new(lexer.tokenize('[[]]'))
    result = parser.parse_statement
    assert_true(result.is_a?(ListNode))
    assert_equal(1, result.parameters.length)
    assert_true(result.parameters[0].is_a?(ListNode))

    parser = Parser.new(lexer.tokenize('[[[], []]]'))
    result = parser.parse_statement
    assert_true(result.is_a?(ListNode))
    assert_equal(1, result.parameters.length)
    assert_true(result.parameters[0].is_a?(ListNode))
    assert_equal(2, result.parameters[0].parameters.length)
    assert_true(result.parameters[0].parameters[0].is_a?(ListNode))
    assert_true(result.parameters[0].parameters[1].is_a?(ListNode))
  end

  def test_list_index_access
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('var[2]'))
    result = parser.parse_statement
    assert_true(result.is_a?(IndexAccessNode))
    assert_true(result.identifier.is_a?(VariableAccessNode))
    assert_true(result.index.is_a?(NumericNode))

    parser = Parser.new(lexer.tokenize('var[2+2]'))
    result = parser.parse_statement
    assert_true(result.is_a?(IndexAccessNode))
    assert_true(result.index.is_a?(BinaryOperationNode))
    assert_true(result.index.left_node.is_a?(NumericNode))
    assert_true(result.index.right_node.is_a?(NumericNode))

    parser = Parser.new(lexer.tokenize('var[2+x]'))
    result = parser.parse_statement
    assert_true(result.is_a?(IndexAccessNode))
    assert_true(result.index.is_a?(BinaryOperationNode))
    assert_true(result.index.left_node.is_a?(NumericNode))
    assert_true(result.index.right_node.is_a?(VariableAccessNode))

    parser = Parser.new(lexer.tokenize('var[]'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))
  end

  def test_list_index_assignment
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('var[2] = True'))
    result = parser.parse_statement
    assert_true(result.is_a?(IndexAssignmentNode))
    assert_true(result.index.is_a?(NumericNode))
    assert_true(result.new_value.is_a?(BooleanNode))

    parser = Parser.new(lexer.tokenize('var[2] = 20!=2'))
    result = parser.parse_statement
    assert_true(result.is_a?(IndexAssignmentNode))
    assert_true(result.index.is_a?(NumericNode))
    assert_true(result.new_value.is_a?(BinaryOperationNode))
    assert_true(result.new_value.left_node.is_a?(NumericNode))
    assert_true(result.new_value.right_node.is_a?(NumericNode))

    parser = Parser.new(lexer.tokenize('var[] = 2'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))
  end

  def test_while_loop
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('while x
      x = x+1  
stop
'))
    result = parser.parse_statement
    assert_true(result.is_a?(WhileNode))
    assert_true(result.condition.is_a?(VariableAccessNode))
    assert_true(result.block.is_a?(StatementsNode))
    assert_true(result.block.statements[0].is_a?(VariableAssignmentNode))

    parser = Parser.new(lexer.tokenize('while not x > 2
      x = x+1  
stop
'))
    result = parser.parse_statement
    assert_true(result.is_a?(WhileNode))
    assert_true(result.condition.is_a?(UnaryOperationNode))
    assert_true(result.condition.node.is_a?(BinaryOperationNode))
    assert_true(result.condition.node.left_node.is_a?(VariableAccessNode))
    assert_true(result.condition.node.right_node.is_a?(NumericNode))
    assert_true(result.block.is_a?(StatementsNode))
    assert_true(result.block.statements[0].is_a?(VariableAssignmentNode))
  end

  def test_for_loop
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('for every x in list
      x = x+1  
stop
'))
    result = parser.parse_statement
    assert_true(result.is_a?(ForLoopNode))
    assert_true(result.list.is_a?(VariableAccessNode))
    assert_true(result.body.is_a?(StatementsNode))
    assert_true(result.body.statements[0].is_a?(VariableAssignmentNode))

    parser = Parser.new(lexer.tokenize('for every x in [1,2,3]
      x = x+1  
stop
'))
    result = parser.parse_statement
    assert_true(result.is_a?(ForLoopNode))
    assert_true(result.list.is_a?(ListNode))
    assert_true(result.body.is_a?(StatementsNode))
    assert_true(result.body.statements[0].is_a?(VariableAssignmentNode))

    parser = Parser.new(lexer.tokenize('for every x in call [1,2,3].flip()
      x = x+1  
stop
'))
    result = parser.parse_statement
    assert_true(result.is_a?(ForLoopNode))
    assert_true(result.list.is_a?(MethodCallNode))
    assert_true(result.body.is_a?(StatementsNode))
    assert_true(result.body.statements[0].is_a?(VariableAssignmentNode))
  end

  def test_open_file
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('load "filename" into x'))
    result = parser.parse_statement
    assert_true(result.is_a?(OpenFileNode))
    assert_true(result.filename.is_a?(TextNode))

    parser = Parser.new(lexer.tokenize('load "filename" + one into x'))
    result = parser.parse_statement
    assert_true(result.is_a?(OpenFileNode))
    assert_true(result.filename.is_a?(BinaryOperationNode))
  end

  def test_dicionary
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('{}'))
    result = parser.parse_statement
    assert_true(result.is_a?(DictNode))
    assert_equal(0, result.pairs.length)

    parser = Parser.new(lexer.tokenize('{key: value}'))
    result = parser.parse_statement
    assert_true(result.is_a?(DictNode))
    assert_equal(1, result.pairs.length)
    assert_equal(2, result.pairs[0].length)
    assert_true(result.pairs[0][0].is_a?(VariableAccessNode))
    assert_true(result.pairs[0][1].is_a?(VariableAccessNode))

    parser = Parser.new(lexer.tokenize('{"key": 2}'))
    result = parser.parse_statement
    assert_true(result.is_a?(DictNode))
    assert_equal(1, result.pairs.length)
    assert_equal(2, result.pairs[0].length)
    assert_true(result.pairs[0][0].is_a?(TextNode))
    assert_true(result.pairs[0][1].is_a?(NumericNode))

    parser = Parser.new(lexer.tokenize('{x: 2+2}'))
    result = parser.parse_statement
    assert_true(result.is_a?(DictNode))
    assert_equal(1, result.pairs.length)
    assert_equal(2, result.pairs[0].length)
    assert_true(result.pairs[0][0].is_a?(VariableAccessNode))
    assert_true(result.pairs[0][1].is_a?(BinaryOperationNode))

    parser = Parser.new(lexer.tokenize('{x: "hello" + "world", y: False, z: 2.33}'))
    result = parser.parse_statement
    assert_true(result.is_a?(DictNode))
    assert_equal(3, result.pairs.length)
    assert_equal(2, result.pairs[0].length)
    assert_equal(2, result.pairs[1].length)
    assert_equal(2, result.pairs[2].length)
    assert_true(result.pairs[0][0].is_a?(VariableAccessNode))
    assert_true(result.pairs[0][1].is_a?(BinaryOperationNode))
    assert_true(result.pairs[1][0].is_a?(VariableAccessNode))
    assert_true(result.pairs[1][1].is_a?(BooleanNode))
    assert_true(result.pairs[2][0].is_a?(VariableAccessNode))
    assert_true(result.pairs[2][1].is_a?(NumericNode))
  end

  def test_import
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('use "filename.nial"'))
    result = parser.parse_statement
    assert_true(result.is_a?(ImportNode))
    assert_true(result.filename.is_a?(TextNode))

    parser = Parser.new(lexer.tokenize('use "filename" + num + ".nial"'))
    result = parser.parse_statement
    assert_true(result.is_a?(ImportNode))
    assert_true(result.filename.is_a?(BinaryOperationNode))
  end

  def test_type_definition
    lexer = Lexer.new

    parser = Parser.new(lexer.tokenize('define type Base
    x = 3
    y = 4
    
    define method constructor()
           return x
    stop
stop
'))
    result = parser.parse_statement
    assert_true(result.is_a?(TypeNode))
    assert_equal(2, result.attributes.length)
    assert_equal(1, result.methods.length)
    assert_equal(nil, result.parent)

    parser = Parser.new(lexer.tokenize('define type Base
    define method constructor()
           return x
    stop
stop
'))
    result = parser.parse_statement
    assert_true(result.is_a?(TypeNode))
    assert_equal(0, result.attributes.length)
    assert_equal(1, result.methods.length)
    assert_equal(nil, result.parent)

    parser = Parser.new(lexer.tokenize('define type Child
    extend Base
    define method constructor()
           return x
    stop
stop
'))
    result = parser.parse_statement
    assert_true(result.is_a?(TypeNode))
    assert_equal(0, result.attributes.length)
    assert_equal(1, result.methods.length)
    assert_false(result.parent == nil)
  end

  def test_utility_definition
    lexer = Lexer.new

    # Utility with no attributes
    parser = Parser.new(lexer.tokenize('define utility Base
    define method add(num)
           return num + num
    stop

    define method subtract(num)
           return num - num
    stop
stop
'))

    result = parser.parse_statement
    assert_true(result.is_a?(UtilityNode))
    assert_equal(0, result.attributes.length)
    assert_equal(2, result.methods.length)

    # Utility with no methods
    parser = Parser.new(lexer.tokenize('define utility Base
    CONST = 4
    ANOTHER = 5
stop
'))

    result = parser.parse_statement
    assert_true(result.is_a?(UtilityNode))
    assert_equal(2, result.attributes.length)
    assert_equal(0, result.methods.length)

    # Utilities cannot inherit
    parser = Parser.new(lexer.tokenize('define utility Child
    extend Base
    CONST = 4
    ANOTHER = 5
stop
'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))
  end

  def test_try_bock
    lexer = Lexer.new

    # Try block with one catch and else
    parser = Parser.new(lexer.tokenize('try
    x = 1 / 0
catch DivisionByZero
      x = 1
else
      x = 2
stop
'))

    result = parser.parse_statement
    assert_true(result.is_a?(TryNode))
    assert_equal(1, result.catch_blocks.length)
    assert_true(result.else_block.is_a?(StatementsNode))

    # Try block with three catchs and no else
    parser = Parser.new(lexer.tokenize('try
    x = 1 / 0
catch DivisionByZero
      x = 1
catch VariableNotDefined
      x = 1
catch ConstantNotDefined
      x = 1
stop
'))

    result = parser.parse_statement
    assert_true(result.is_a?(TryNode))
    assert_equal(3, result.catch_blocks.length)
    assert_nil(result.else_block)

    # Forget stop
    parser = Parser.new(lexer.tokenize('try
    x = 1 / 0
else
    x = 2
'))
    result = parser.parse_statement
    assert_true(result.is_a?(UnexpectedTokenError))
  end
end
                

