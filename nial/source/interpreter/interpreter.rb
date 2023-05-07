# coding: utf-8
require_relative "../datatypes/number"
require_relative "../datatypes/text"
require_relative "../datatypes/list"
require_relative "../datatypes/function"
require_relative "../datatypes/dictionary"
require_relative "../datatypes/type_method"
require_relative "../datatypes/type"
require_relative "../scope/scope"
require_relative "../scope/function_scope"
require_relative "../scope/type_scope"
require_relative "../scope/utility_scope"
require_relative "../actions/actions"
require_relative "../lexer/lexer"
require_relative "../parser/parser"
require_relative "../datatypes/builtin_utilities/file_manager"
require_relative "../datatypes/builtin_utilities/io_manager"

##
# The interpreter is responsible for evaluating the abstract syntax tree.
#
# ==== Methods
# #evaluate

class Interpreter

  ##
  # The evaluate method is the starting point of evaluating an abtract syntax tree.
  # Call this method and pass the root node and the global scope to start evaluating
  # the program.
  
  def Interpreter.evaluate(node, scope)
    # This method is used to redirect all nodes to the correct method
    case node
    when NumericNode then return self.evaluate_number(node, scope)
    when TextNode then return self.evaluate_text(node, scope)
    when BooleanNode then return self.evaluate_boolean(node, scope)
    when NullNode then return self.evaluate_null(node, scope)
    when BinaryOperationNode then return self.evaluate_binary_operation(node, scope)
    when UnaryOperationNode then return self.evaluate_unary_operation(node, scope)
    when VariableAssignmentNode then return self.evaluate_variable_assignment(node, scope)
    when VariableAccessNode then return self.evaluate_variable_access(node, scope)
    when StatementsNode then return self.evaluate_statements(node, scope)
    when DisplayNode then return self.evaluate_display(node, scope)
    when UserInputNode then return self.evaluate_user_input(node, scope)
    when IfStatementNode then return self.evaluate_if_statement(node, scope)
    when FunctionDefinitionNode then return self.evaluate_function_definition(node, scope)
    when FunctionCallNode then return self.evaluate_function_call(node, scope)
    when ReturnNode then return self.evaluate_return_statement(node, scope)
    when CountLoopNode then return self.evaluate_count_loop(node, scope)
    when BreakNode then return self.evaluate_break(node, scope)
    when NextNode then return self.evaluate_next(node, scope)
    when ListNode then return self.evaluate_list(node, scope)
    when IndexAccessNode then return self.evaluate_index_access_node(node, scope)
    when IndexAssignmentNode then return self.evaluate_index_assignment_node(node, scope)
    when MethodCallNode then return self.evaluate_method_call(node, scope)
    when WhileNode then return self.evaluate_while_loop(node, scope)
    when ForLoopNode then return self.evaluate_for_loop(node, scope)
    when OpenFileNode then return self.evaluate_open_file_node(node, scope)
    when ImportNode then return self.evaluate_import_node(node, scope)
    when DictNode then return self.evaluate_dictionary(node, scope)
    when TypeNode then return self.evaluate_type_definition(node, scope)
    when TypeInitNode then return self.evaluate_type_init(node, scope)
    when AttributeAccessNode then return self.evaluate_attribute_access(node, scope)
    when TryNode then return self.evaluate_try_block(node, scope)
    when UtilityNode then return self.evaluate_utility_definition(node, scope)
    when ConstantAssignmentNode then return self.evaluate_constant_assignment(node, scope)
    else return node
    end
  end

  private

  def Interpreter.evaluate_number(node, scope)
    # Return a new instance of the type Number
    return Number.new(node.value)
  end

  def Interpreter.evaluate_boolean(node, scope)
    # Return a new instance of the type Boolean
    return Boolean.new(node.value)
  end

  def Interpreter.evaluate_null(node, scope)
    # Return a new instance of the type Null
    return Null.new(node.value)
  end

  def Interpreter.evaluate_text(node, scope)
    # Return a new instance of the type Text
    return Text.new(node.value)
  end

  def Interpreter.evaluate_binary_operation(node, scope)
    # This method is used for evaluating a binary operation.
    pos = node.operator.position
    
    left = self.evaluate(node.left_node, scope)
    if left.is_a?(Error) then return left end
    right = self.evaluate(node.right_node, scope)
    if right.is_a?(Error) then return right end

    case node.operator.type
    when :ADDITION then result = left.addition(right, scope, pos)
    when :SUBTRACTION then result = left.subtraction(right, scope, pos)
    when :MULTIPLICATION then result = left.multiplication(right, scope, pos)
    when :DIVISION then result = left.division(right, scope, pos)
    when :MODULO then result = left.modulo(right, scope, pos)
    when :EXPONENT then result = left.power(right, scope, pos)
    when :EQUALS then result = left.equals(right, scope, pos)
    when :NOT_EQUALS then result = left.not_equals(right, scope, pos)
    when :GREATER_THAN then result = left.greater_than(right, scope, pos)
    when :LESS_THAN then result = left.less_than(right, scope, pos)
    when :EQUALS_OR_GREATER_THAN then result = left.equals_or_greater_than(right, scope, pos)
    when :EQUALS_OR_LESS_THAN then result = left.equals_or_less_than(right, scope, pos)
    when :AND then result = left.and(right, scope, pos)
    when :OR then result = left.or(right, scope, pos)
    when :AT then result = left.get_attribute(right, scope, pos)
    when :ADDITION_ASSIGNMENT then result = left.addition_assignment(right, scope, pos)
    when :SUBTRACTION_ASSIGNMENT then result = left.subtraction_assignment(right, scope, pos)
    when :DIVISION_ASSIGNMENT then result = left.division_assignment(right, scope, pos)
    when :MULTIPLICATION_ASSIGNMENT then result = left.multiplication_assignment(right, scope, pos)
    else return
    end
    return result
  end

  def Interpreter.evaluate_unary_operation(node, scope)
    right_node = self.evaluate(node.node, scope)
    if right_node.is_a?(Error) then return right_node end
    case node.operator_token.type
    when :SUBTRACTION
      if right_node.is_a?(Number)
        return right_node.multiplication(Number.new(-1), scope, node.position)
      end
    when :ADDITION
      if right_node.is_a?(Number)
        return right_node
      end
    when :NOT
      right_node = right_node.convert_to_boolean(scope, node.position)
      if right_node.is_a?(Error) then return right_node end
      return Boolean.new(!right_node.value)
    end
  end

  def Interpreter.evaluate_variable_assignment(node, scope)
    # Evaluate the value that should be assigned to the identifier
    value = self.evaluate(node.value, scope)
    if value.is_a?(Error) then return value end

    # Add the identifier and the value to the current scope
    result = scope.set_variable(node.identifier, value)
    return result
  end

  def Interpreter.evaluate_variable_access(node, scope)
    # Returns the requested variable, or an error if the variable is not defined.
    variable = scope.get_variable(node.identifier)
    if variable.is_a?(VariableNotDefined)
      simular_variable = scope.find_simular(node.identifier)
      if simular_variable
        variable.add_suggestion("Did you mean #{simular_variable}?")
      end
    end
    return variable
  end

  def Interpreter.evaluate_display(node, scope)
    # Evaluate the value that should be displayed
    result = self.evaluate(node.value_node, scope)
    if result.is_a?(Error) then return result end
    IOManager.output(result, scope, node.position)
  end

  def Interpreter.evaluate_user_input(node, scope)
    value = IOManager.input(scope, node.position)
    if value.is_a?(Error) then return value end
    
    scope.set_variable(node.identifier, value)
    return value
  end

  def Interpreter.evaluate_statements(node, scope)
    # Check if we are evaluating statements inside a function or method
    inside_function = self.inside_function?(scope)

    # Go through every statement in the array
    node.statements.each {|statement|
      # Evaluate the statement
      result = self.evaluate(statement, scope)
      if result.is_a?(Error) then return result
      # Check if the result is a return-action.
      elsif result.is_a?(ReturnAction)
        return self.handle_return(result, scope, node.position, inside_function)
      # Check if the result is a break-action
      elsif result.is_a?(BreakAction)
        return self.handle_break(result, scope, node.position)
      elsif result.is_a?(NextAction)
        return self.handle_next(result, scope, node.position)
      end
    }
    if inside_function then return Null.new(nil) end
  end

  def Interpreter.evaluate_if_statement(node, scope)
    # Go through the if and else if-branches one by one
    node.branches.each {|branch|
      # Evaluate the branch condition
      condition = self.evaluate(branch.condition, scope)
      if condition.is_a?(Error) then return condition end
      # Convert the result to a boolean
      condition = condition.convert_to_boolean(scope, node.position)
      if condition.is_a?(Error) then return condition end

      # If the condition evaluates to true, evaluate the corresponding block and return it.
      if condition.value
        return self.evaluate(branch.block, Scope.new("if statement", scope, node.position))
      end
    }
    # If no condition is true, evaluate the else-block instead if it exists.
    if node.else_block
      return self.evaluate(node.else_block, Scope.new("if statement", scope, node.position))
    end
  end


  def Interpreter.evaluate_function_definition(node, scope)
    case node.type
    when :DEFINE_METHOD
      scope.set_variable(node.name, TypeMethod.new(node.name.value, node.parameters, node.block))
    when :DEFINE_FUNCTION
      scope.set_variable(node.name, Function.new(node.name.value, node.parameters, node.block))
    when :PIPE
      return Function.new("anonymous", node.parameters, node.block)
    end
  end

  def Interpreter.evaluate_function_call(node, scope)
    arguments = self.get_arguments(node.arguments, scope)
    if arguments.is_a?(Error) then return arguments end

    # Evaluate the function that should be called
    function = self.evaluate(node.name, scope)
    if function.is_a?(Error) then return function end

    # Call the function, this can return an argument-error or invalid datatype error
    return function.call(arguments, scope, node.position)
  end

  def Interpreter.evaluate_return_statement(node, scope)
    # Return a Null-object if no return value is provided
    if node.return_value == nil then
      return ReturnAction.new(Null.new(nil))
    # Else return the value provided
    else
      value = self.evaluate(node.return_value, scope)
      if value.is_a?(Error) then return value end
      return ReturnAction.new(value)
    end
  end

  def Interpreter.evaluate_count_loop(node, scope)
    # Evaluate the starting number
    from = self.evaluate(node.from, scope)
    if from.is_a?(Error) then return from end
    from = from.convert_to_number(scope, node.position)
    if from.is_a?(Error) then return from end

    # Evaluate the ending number
    to = self.evaluate(node.to, scope)
    if to.is_a?(Error) then return to end
    to = to.convert_to_number(scope, node.position)
    if to.is_a?(Error) then return to end

    # Decide if the counting should increase or decrease
    if to.value > from.value then step = 1 else step = -1 end

    # Start the loop, listen for break and return actions
    (from.value..to.value).step(step).each { |number|
      new_scope = Scope.new("count loop", scope, node.position)
      new_scope.set_variable(node.identifier, Number.new(number))
      result = self.evaluate(node.body, new_scope)
      if result.is_a?(Error) then return result
      elsif result.is_a?(BreakAction) then break
      elsif result.is_a?(ReturnAction) then return result end
    } 
  end

  def Interpreter.evaluate_break(node, scope)
    return BreakAction.new
  end
  
  def Interpreter.evaluate_next(node, scope)
    return NextAction.new
  end

  def Interpreter.evaluate_list(node, scope)
    list = List.new
    node.parameters.each {|value|
      result = self.evaluate(value, scope)
      if result.is_a?(Error) then return result end
      list.add(result)
    }
    return list
  end

  def Interpreter.evaluate_index_access_node(node, scope)
    # The method is used for accessing an index or key
    
    # Evaluate the identifier
    identifier = self.evaluate(node.identifier, scope)
    if identifier.is_a?(Error) then return identifier end

    # Evaluate the index
    index = self.evaluate(node.index, scope)
    if index.is_a?(Error) then return index end

    # Ask the object for the object at that index.
    # The method will return an error if this is an illegal operation
    return identifier.get_index(index, scope, node.position)
  end

  def Interpreter.evaluate_index_assignment_node(node, scope)
    identifier = self.evaluate(node.identifier, scope)
    if identifier.is_a?(Error) then return identifier end
    index = self.evaluate(node.index, scope)
    if index.is_a?(Error) then return index end
    new_value = self.evaluate(node.new_value, scope)
    if new_value.is_a?(Error) then return new_value end
    
    return identifier.set_index(index, new_value, scope, node.position)
  end

  def Interpreter.evaluate_method_call(node, scope)
    # Find the object
    object = self.evaluate(node.identifier, scope)
    if object.is_a?(Error) then return object end

    # Evaluate all arguments sent to the method
    arguments = self.get_arguments(node.arguments, scope)
    if arguments.is_a?(Error) then return arguments end

    object_type = self.get_object_type(node, object)

    if object.is_a?(Type)
      # If the object is a Type-object, check if the object has an
      # user defined method with this name.
      # If not, we continue and check for built in methods
      method = object.get_method(node.method, object.scope, node.position)
      if not method.is_a?(Error)
        return method.call(arguments, object.scope, node.position)
      end
    end
    
    arguments << scope
    arguments << node.position
    
    return self.call_builtin_method(node, scope, object, arguments, object_type)
  end

  def Interpreter.evaluate_while_loop(node, scope)
    # Evaluate the condition and make sure it is a boolean
    condition = self.evaluate(node.condition, scope)
    if condition.is_a?(Error) then return condition end
    condition = condition.convert_to_boolean(scope, node.position)
    if condition.is_a?(Error) then return condition end

    # Run the block as long as the condition is true
    while condition.value
      new_scope = Scope.new("while loop", scope, node.position)
      result = self.evaluate(node.block, new_scope)
      if result.is_a?(Error) then return result
      elsif result.is_a?(BreakAction) then break
      elsif result.is_a?(ReturnAction) then return result end

      # Evaluate the condition again to see if the block should be run again
      condition = self.evaluate(node.condition, new_scope)
      if condition.is_a?(Error) then return condition end
      condition = condition.convert_to_boolean(new_scope, node.position)
      if condition.is_a?(Error) then return condition end
    end  
  end

  def Interpreter.evaluate_for_loop(node, scope)
    list = self.evaluate(node.list, scope)
    if list.is_a?(Error) then return list end
    list = list.convert_to_list(scope, node.position)
    if list.is_a?(Error) then return list end
    
    list.value.each {|i|
      new_scope = Scope.new("for loop", scope, node.position)
      value = i
      if node.copy then value = value.copy(scope, node.position) end
      if value.is_a?(Error) then return value end
      
      new_scope.set_variable(node.identifier, value)
      result = self.evaluate(node.body, new_scope)
      if result.is_a?(Error) then return result
      elsif result.is_a?(BreakAction) then return
      elsif result.is_a?(ReturnAction) then return result end
    }
  end

  def Interpreter.evaluate_open_file_node(node, scope)
    filename = self.evaluate(node.filename, scope)
    if filename.is_a?(Error) then return filename end

    return FileManager.read(filename, scope, node.position)
  end

  def Interpreter.evaluate_import_node(node, scope)
    # Evaluate the filename
    filename = self.evaluate(node.filename, scope)
    if filename.is_a?(Error) then return filename end
    # Convert the filename to text, this is mainly because this method
    # will return an error if the object cannot be converted to text
    # This makes sure we have the correct datatype.
    filename = filename.convert_to_text(scope, node.position)
    if filename.is_a?(Error) then return filename end

    # Find the full path to the file relative to the current file
    input_file_path = File.expand_path(node.position.file)
    file_path = File.join(File.dirname(input_file_path), filename.value)

    # Makes sure the file hasnt been included already
    if scope.file_is_included(file_path) then return end

    # Get the data from the file
    begin
      data = File.read(file_path)
    rescue
      return FileError.new("Failed to open \"#{file_path}\".", scope, node.position)
    end
    
    # Collect tokens
    lexer = Lexer.new
    result = lexer.tokenize(data, filename.value)
    if result.is_a?(Error) then return result end
    
    # Parse the tokens
    parser = Parser.new(result)
    result = parser.parse
    if result.is_a?(Error) then return result end

    # Evaluate the abtract syntax tree and return the result
    return self.evaluate(result, scope)   
  end

  def Interpreter.evaluate_dictionary(node, scope)
    pairs = self.collect_key_values(node, scope)
    if pairs.is_a?(Error) then return pairs end

    return Dictionary.new(pairs)
  end

  def Interpreter.evaluate_type_definition(node, scope)
    # Find the parent scope, can be another type this type
    # should inherit from or the global scope
    parent_scope = self.find_parent(node.parent, scope, node.position)
    if parent_scope.is_a?(Error) then return parent_scope end

    # Create a new template
    type_template = TypeScope.new(node.identifier.value, parent_scope, node.position)
      
    # Evaluate the attributes of the type
    potential_error = self.collect_attributes(node.attributes, type_template)
    if potential_error.is_a?(Error) then return potential_error end

    # Evaluate the methods definitions of the type
    potential_error = self.collect_methods(node.methods, type_template)
    if potential_error.is_a?(Error) then return potential_error end
    
    # Save the template to the current scope so it is possible
    # to create instances of the type later.
    scope.type_templates << type_template
  end

  def Interpreter.find_parent(parent, scope, position)
    if parent
      return scope.get_type(parent.value, scope, position)
    else
      return scope
    end
  end

  def Interpreter.collect_methods(methods, scope)
    methods.each {|method|
      method = self.evaluate(method, scope)
      if method.is_a?(Error) then return method end
    }
  end

  def Interpreter.collect_attributes(attributes, scope)
    attributes.each {|attribute|
      attribute = self.evaluate(attribute, scope)
      if attribute.is_a?(Error) then return attribute end
    }
  end

  def Interpreter.evaluate_type_init(node, scope)
    # Look for the type template in the current scope
    type = scope.get_type(node.identifier.value, scope, node.position)
    if type.is_a?(Error) then return type end

    # Evaluate the arguments passed to the constructor
    args = self.get_arguments(node.arguments, scope)
    if args.is_a?(Error) then return args end

    # If the object is a built in object, it will be created in a different way
    if !type.is_a?(Scope)
      return self.init_builtin_type(type, args, scope, node.position)
    end  

    # Create a new instance of the type-scope by copying the template
    new_instance = type.copy(type, node.position)

    potential_error = self.call_constructor(type, args, new_instance, node.position)
    if potential_error.is_a?(Error) then return potential_error end

    # Return a new instance of the type
    return Type.new(node.identifier.value, new_instance)  
  end

  def Interpreter.call_constructor(type, arguments, new_instance, position)
    constructor = type.get_method("constructor")
    if constructor.is_a?(Error) then return constructor end

    # Call the constructor
    result = constructor.call(arguments, new_instance, position)
    if result.is_a?(Error) then return result end
  end

  def Interpreter.evaluate_attribute_access(node, scope)
    object = self.evaluate(node.identifier, scope)
    if object.is_a?(Error) then return object end

    return object.get_attribute(node.attribute, scope, node.position)
  end

  def Interpreter.evaluate_try_block(node, scope)
    result = self.evaluate(node.try_block, scope)
    if !result.is_a?(Error) then return result end

    node.catch_blocks.each {|error, block|
      begin
        if result.is_a?(Module.const_get(error.value))
          return self.evaluate(block, scope)
        end
      rescue
        next
      end
    }

    if node.else_block
      return self.evaluate(node.else_block, scope)
    end
  end

  def Interpreter.evaluate_utility_definition(node, scope)
    utility_scope = UtilityScope.new(node.identifier.value, node.position)
    
    # Evaluate the attributes of the utility
    potential_error = self.collect_attributes(node.attributes, utility_scope)
    if potential_error.is_a?(Error) then return potential_error end   

    # Evaluate the methods definitions of the utility
    potential_error = self.collect_methods(node.methods, utility_scope)
    if potential_error.is_a?(Error) then return potential_error end

    # Create an instance of the utility
    utility = Type.new(node.identifier.value, utility_scope)
    return scope.set_variable(node.identifier, utility)
  end

  def Interpreter.evaluate_constant_assignment(node, scope)
    value = self.evaluate(node.value, scope)
    if value.is_a?(Error) then return value end
    
    return scope.set_variable(node.identifier, value)
  end

  def Interpreter.get_arguments(args, scope)
    arguments = Array.new
    args.each {|a|
      if (argument = self.evaluate(a, scope)).is_a?(Error) then return argument end
      arguments << argument
    }
    return arguments
  end

  def Interpreter.call_builtin_method(node, scope, object, arguments, object_type)
    begin
      result = object.send(node.method.value.to_sym, *arguments)
      if not result then result = Null.new(nil) end
      return result
    rescue ArgumentError
      if object.class.is_a?(Class)
        expected = object.method(node.method.value.to_sym).arity - 2
      elsif object.is_a?(Type)
        expected = Type.instance_method(node.method.value.to_sym).arity - 2
      else
        expected = object.class.instance_method(node.method.value.to_sym).arity - 2
      end
      return WrongNumberOfArguments.new(arguments.length-2, expected, scope, node.position)
    rescue NameError
      return MethodMissing.new("Method missing, #{object_type} has no method called \"#{node.method.value.to_sym}\"", scope, node.position)
    end
  end

  def Interpreter.get_object_type(node, object)
    if object.is_a?(Type)
      return object.name
    elsif object.is_a?(Null)
      return object.class
    else
      return object.to_s
    end
  end

  def Interpreter.init_builtin_type(type, arguments, scope, position)
    begin
      return type.send(:new, *arguments)
    rescue ArgumentError
      expected = type.instance_method(:initialize).arity
      return WrongNumberOfArguments.new(arguments.length, expected, scope, position)
    end
  end

  def Interpreter.handle_next(result, scope, position)
    # If we are in the global scope we return an error.
    if scope.parent == nil then
      return NextError.new(scope, position)
    else
      # Else we return the next-action
      return result
    end
  end

  def Interpreter.handle_break(result, scope, position)
    # If we are in the global scope we return an error.
    if scope.parent == nil then
      return BreakError.new(scope, position)
    else
      # Else we return the break-action
      return result
    end
  end

  def Interpreter.handle_return(result, scope, position, inside_function)
    # If we are inside a function or method, we should return the returned value
    if inside_function then return result.value
    # If we get a return-action in the global scope we return an error.
    elsif scope.parent == nil then
      return ReturnError.new(scope, node.position)
    else return result
    end
  end

  def Interpreter.inside_function?(scope)
    return [FunctionScope, MethodScope].include?(scope.class)
  end

  def Interpreter.collect_key_values(node, scope)
    # Find all key-value-pairs that the dictionary should
    # be initialized with.
    pairs = Array.new
    node.pairs.each {|pair|
      key = self.evaluate(pair[0], scope)
      if key.is_a?(Error) then return key end
      # Keys must be Number objects or Text objects.
      if ![Text, Number].include?(key.class)
        return InvalidDatatype.new("Dictionary keys must be Text or Numbers", scope, node.position)
      end
      value = self.evaluate(pair[1], scope)
      if value.is_a?(Error) then return value end
      pairs << [key, value]
    }
    return pairs
  end
end
