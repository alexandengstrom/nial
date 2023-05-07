##
# The base class that all nodes inherits from.
class BaseNode
  attr_accessor :position

  ##
  # Creates a BaseNode
  def initialize(position)
    @position = position
  end
end

##
# The interface of all terminals.
class Terminal < BaseNode
  attr_accessor :line, :column, :value

  ##
  # Creates a Terminal
  def initialize(token)
    super(token.position)
    @type = token.type
    @value = token.value
  end

  def to_string
    return @value
  end
end

##
# A BooleanNode is created when a Boolean-token is found.
class BooleanNode < Terminal

  ##
  # Creates a BooleanNode
  def initialize(token)
    super(token)
  end
end

##
# A NullNode is created when a Null-token is found.
class NullNode < Terminal

  ##
  # Creates a NullNode
  def initialize(token)
    super(token)
  end
end

##
# A NumericNode is created when a Number-token is found.
class NumericNode < Terminal

  ##
  # Creates a NumericNode.
  def initialize(token)
    super(token)
  end
end

##
# A TextNode is created when a Text-token is found.
class TextNode < Terminal

  ##
  # Creates a TextNode
  def initialize(token)
    super(token)
    @value = @value[1..@value.length-2]
    @value = @value.gsub("\\n", "\n")
    @value = @value.gsub("\\w", "\w")
    #@value = @value.gsub("\d", "\\d")
    @value = @value.gsub("\\t", "    ")
    @value = @value.gsub('\\"', '"')
  end
end

##
# A BinaryOperationNode is created everytime the Parser founds a binary operator
# and two operands.
class BinaryOperationNode < BaseNode
  attr_accessor :left_node, :right_node, :operator

  ##
  # Creates a new BinaryOperationNode.
  def initialize(left_node, operator_token, right_node)
    super(left_node.position)
    @left_node = left_node
    @right_node = right_node
    @operator = operator_token
  end

  def to_string
    return "#{@left_node.to_string} #{@operator.to_string} #{@right_node.to_string}"
  end
end

##
# A UnaryOperationNode is created everytime the Parser founds a unary operator and
# one operand.
class UnaryOperationNode < BaseNode
  attr_accessor :node, :operator_token

  ##
  # Creates a new UnaryOperationNode.
  def initialize(node, operator_token)
    super(node.position)
    @node = node
    @operator_token = operator_token
  end

  def to_string
    space = ""
    space = " " if @operator_token.type == :NOT
    return "#{@operator_token.to_string}#{space}#{@node.to_string}"
  end
end

##
# A VariableAssignmentNode is created when the Parser founds
# one idenfifier, one assignment operator and a valid expression.
class VariableAssignmentNode < BaseNode
  attr_accessor :identifier, :value

  ##
  # Creates a VariableAssignmentNode.
  def initialize(identifier_token, value)
    super(identifier_token.position)
    @identifier = identifier_token
    @value = value
  end

  def to_string
    return "#{@identifier} = #{@value}"
  end
end

##
# A ConstantAssignmentNode is created when the Parser founds
# one constant idenfifier, one assignment operator and a valid expression.
class ConstantAssignmentNode < BaseNode
  attr_accessor :identifier, :value

  ##
  # Creates a ConstantAssignmentNode
  def initialize(identifier, value)
    super(identifier.position)
    @identifier = identifier
    @value = value
    @position = position
  end

  def to_string
    return "#{@identifier} = #{@value}"
  end
end

##
# A VariableAccessNode is created when the Parses founds an identifier.
class VariableAccessNode < BaseNode
  attr_accessor :identifier

  ##
  # Creates a VariableAccessNode.
  def initialize(identifier_token)
    super(identifier_token.position)
    @identifier = identifier_token
  end

  def to_string
    return "#{@identifier.value}"
  end
end

##
# A DisplayNode is created when the Parser finds the keyword "display"
# followed by a valid expression.
class DisplayNode < BaseNode
  attr_accessor  :value_node

  ##
  # Creates a DisplayNode.
  def initialize(value_node, position)
    super(position)
    @value_node = value_node
  end
end

##
# A UserInputNode is created when the Parser finds the keyword
# "let user assign" followed by an identifier.
class UserInputNode < BaseNode
  attr_accessor :identifier

  ##
  # Creates a UserInputNode.
  def initialize(identifier_token, position)
    super(position)
    @identifier = identifier_token
  end
end

##
# A StatementsNode is created when a block of code is parsed.
# A StatementsNode stores an array of Statements.
class StatementsNode < BaseNode
  attr_accessor :statements
  def initialize(statements, position)
    super(position)
    @statements = statements
  end
end

##
# An IfBranchNode stores a condition and a block of code.
class IfBranchNode < BaseNode
  attr_accessor :condition, :block

  def initialize(condition, block, position)
    super(position)
    @condition = condition
    @block = block
  end
end

##
# An IfStatementNode is created when an if statement is used in the language.
# An IfStatementNode stores all if and elif branches as IfBranchNode objects
# and also an else block if it exists.
class IfStatementNode < BaseNode
  attr_accessor :branches, :else_block
  def initialize(branches, else_block, position)
    super(position)
    @branches = branches
    @else_block = else_block
  end
end

##
# A FunctionDefinitionNode is created when a function is defined in the language.
# Stores the name, parameters, block of code and what type of function it is.
class FunctionDefinitionNode < BaseNode
  attr_accessor :name, :parameters, :block, :type
  def initialize(name, parameters, block, type, position)
    super(position)
    @name = name
    @parameters = parameters
    @block = block
    @type = type
  end
end

##
# A FunctionCallNode is created when a function is called.
# Stores the name of the function that is getting called and the
# arguments provided.
class FunctionCallNode < BaseNode
  attr_accessor :name, :arguments
  def initialize(name, arguments, position)
    super(position)
    @name = name
    @arguments = arguments
  end

  def to_string
    arguments = Array.new
    @arguments.each {|a| arguments << a.value}
    return "call #{@name.identifier.value}(#{arguments.join(', ')})"
  end
end

##
# A ReturnNode is created when the keyword Return is used in the language.
# Stores a return value if provided.
class ReturnNode < BaseNode
  attr_accessor :return_value
  def initialize(return_value, position)
    super(position)
    @return_value = return_value
  end
end

##
# A CountLoopNode is created when a range-based loop is used in the language.
# Stores the start and stop of the iteration,
# the name of the identifier, and the block of code.
class CountLoopNode < BaseNode
  attr_accessor :identifier, :from, :to, :body
  def initialize(identifier, from, to, body, position)
    super(position)
    @identifier = identifier
    @from = from
    @to = to
    @body = body
  end

  def to_string(from, to)
    return "count #{@identifier.value} from #{from.display} to #{to.display}"
  end
end

##
# A BreakNode is created when the break keyword is used in the language.
class BreakNode < BaseNode
  def initialize(position)
    super(position)
  end
end

##
# A NextNode is created when the next keyword is used in the language.
class NextNode < BaseNode
  def initialize(position)
    super(position)
  end
end

##
# An IndexAssignmentNode is created when the user assigns a value to
# an index of a Text object, List object or Dictionary.
# Stores the index and the new value.
class IndexAssignmentNode < BaseNode
  attr_accessor :identifier, :index, :new_value
  def initialize(identifier, index, new_value, position)
    super(position)
    @identifier = identifier
    @index = index
    @new_value = new_value
  end

  def to_string(identifier, index)
    return "#{identifier.to_string}[#{index.to_string}]"
  end
end

##
# An IndexAccessNode is created when the user wants to access
# a specific index of a Text object, List object or Dictionary object.
# Stores the index.
class IndexAccessNode < BaseNode
  attr_accessor :identifier, :index
  def initialize(identifier, index, position)
    super(position)
    @identifier = identifier
    @index = index
  end

  def to_string(*args)
    if args.empty?
      return "#{@identifier.to_string}[#{@index.to_string}]"
    end
    return "#{identifier.to_string}[#{index.to_string}]"
  end
end

##
# A ListNode is created when a new list is initialized using square brackets.
# Stores the values that should be in the List object.
class ListNode < BaseNode
  attr_accessor :parameters
  def initialize(parameters, position)
    super(position)
    @parameters = parameters
  end
end

##
# A DictNode is created when a new Dictionary is initialized using curly brackets.
# Stores all key-value pairs provided in the initialization.
class DictNode < BaseNode
  attr_accessor :pairs
  def initialize(pairs, position)
    super(position)
    @pairs = pairs
  end
end

##
# A MethodCallNode is created when a method is called.
# Stores the object, the method name and the arguments.
class MethodCallNode < BaseNode
  attr_accessor :identifier, :method, :arguments
  def initialize(identifier, method, arguments, position)
    super(position)
    @identifier = identifier
    @method = method
    @arguments = arguments
  end

  def to_string(object, arguments)
    return "call " + object.display + "(" + arguments.map{|v| "#{v.display}"}.join(", ") + ")"
  end
end

##
# A WhileNode is created when a while loop is used in the language.
# Stores a condition and a block of code.
class WhileNode < BaseNode
  attr_accessor :condition, :block
  def initialize(condition, block, position)
    super(position)
    @condition = condition
    @block = block
  end
end

##
# A ForLoopNode is created when a for loop is used in the language.
# Stores the identifier, the List that should be iterated, the
# block of code and if the variable should be copied or not.
class ForLoopNode < BaseNode
  attr_accessor :identifier, :list, :body, :copy
  def initialize(identifier, list, body, copy, position)
    super(position)
    @identifier = identifier
    @list = list
    @body = body
    @copy = copy
  end

  def to_string(list)
    return "for every #{@identifier.value} in #{list.display}"
  end
end

##
# An OpenFileNode is created when the user wants to load a file.
# Stors the filename and the identifier that should store the
# contents of the file.
class OpenFileNode < BaseNode
  attr_accessor :filename, :identifier
  def initialize(filename, identifier, position)
    super(position)
    @filename = filename
    @identifier = identifier
  end

  def to_string(filename)
    return "load \"#{filename}\" into #{@identifier.value}"
  end
end

##
# An ImportNode is created when the use keyword is used in the language.
# Stores the filename that should be included.
class ImportNode < BaseNode
  attr_accessor :filename
  def initialize(filename, position)
    super(position)
    @filename = filename
  end

  def to_string(filename)
    return "use #{filename.value}"
  end
end

##
# A TypeNode is created when a new Type object is defined.
# Stores the name of the Type, all attributes and methods and
# if the type should inherit or not.
class TypeNode < BaseNode
  attr_accessor :identifier, :attributes, :methods, :parent
  def initialize(identifier, attributes, methods, parent, position)
    super(position)
    @identifier = identifier
    @attributes = attributes
    @methods = methods
    @parent = parent
  end
end

##
# A TypeInitNode is created when a new Type object is initialized.
# Stores the name of the Type and the arguments that will be
# sent to the constructor.
class TypeInitNode < BaseNode
  attr_accessor :identifier, :arguments
  def initialize(identifier, arguments, position)
    super(position)
    @identifier = identifier
    @arguments = arguments
  end
end

##
# An AttributeAccessNode is created when the @ operator is used.
# Stores the object and attribute.
class AttributeAccessNode < BaseNode
  attr_accessor :identifier, :attribute
  def initialize(identifier, attribute, position)
    super(position)
    @identifier = identifier
    @attribute = attribute
  end
end

##
# A TryNode is created when the keyword try is used in the language.
# Stores the try block and all catch blocks that is provided.
# Also stores an else block if provided.
class TryNode < BaseNode
  attr_accessor :try_block, :catch_blocks, :else_block
  def initialize(try_block, catch_blocks, else_block, position)
    super(position)
    @try_block = try_block
    @catch_blocks = catch_blocks
    @else_block = else_block
  end
end

##
# An UtilityNode is created when a new Utility object is defined.
# Stores the name of the Utility, the attributes and methods.
class UtilityNode < BaseNode
  attr_accessor :identifier, :attributes, :methods
  def initialize(identifier, attributes, methods, position)
    super(position)
    @identifier = identifier
    @attributes = attributes
    @methods = methods
  end
end
