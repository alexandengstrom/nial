# coding: utf-8
require_relative '../nodes/nodes'
require_relative '../exceptions/error'
require_relative "../documentation/xml_writer"

##
# The Parser is responsible for translating the Token stream returned by
# the Lexer to an abstract syntax tree.
class Parser

  ##
  # Creates a new Parser.
  def initialize(tokens)
    @assignment_operators = [:ADDITION_ASSIGNMENT, :SUBTRACTION_ASSIGNMENT,
                             :DIVISION_ASSIGNMENT, :MULTIPLICATION_ASSIGNMENT]
    @expression_operators = [:ADDITION, :SUBTRACTION]
    @term_operators = [:MULTIPLICATION, :DIVISION, :MODULO]
    @exponent_operator = [:EXPONENT]
    @boolean_operators = [:EQUALS, :NOT_EQUALS, :EQUALS_OR_GREATER_THAN,
                          :EQUALS_OR_LESS_THAN, :GREATER_THAN, :LESS_THAN]
    @logical_operators = [:AND, :OR]
    @control_structure = [:IF]
    
    @tokens = tokens
    @position = -1
    @current_token = nil
    self.move_cursor
  end

  ##
  # This method will parse the entire program. The method will return the
  # starting node of the abstract syntax tree.
  def parse
    if @tokens.empty? then return end
    result = self.parse_statements
    if not result.is_a?(Error) and @tokens[@position+1]
      return ExpectedEndOfInputError.new(@current_token, @current_token.position)
    end
    return result
  end

  ##
  # Parses statements until a stop-token occurs. This method is called
  # everytime there is a block of code that should be parsed.
  def parse_statements(stop=[]) 
    position = secure_position
    statements = []

    # Skip newlines before the first statement
    self.skip_newlines
    
    # Continue to parse while there is tokens left or if the stop-token occurs
    while @current_token and not stop.include?(@current_token.type)
      if @current_token and not stop.include?(@current_token.type)
        # Parse a statement and add it to the array of statements if
        # it isnt an error
        statement = parse_statement
        if statement.is_a?(Error) then return statement end
        statements << statement

        # A statement should end with a newline-character
        if self.expect(:NEWLINE)
          self.move_cursor
        elsif @current_token and not stop.include?(@current_token.type)
          
          error = UnexpectedTokenError.new(secure_token, "end of line", secure_position)
          case @current_token.type
          when :LEFT_PAREN
            error.add_suggestion("Use \"call\" keyword if you want to call a function")
          when :DOT
            error.add_suggestion("Use \"call\" keyword if you want to call a method")
          end
          return error
        end
      end

      # Skip newlines before next statement
      self.skip_newlines
    end

    # Return all the parsed statements as a StatementsNode.
    return StatementsNode.new(statements, position)
  end

  ##
  # This method parses one statement. This method is called from the
  # parse_statements method as long as there is statements to parse.
  def parse_statement
    case @current_token.type
    when :USE
      return parse_import
    when :LOAD
      return parse_load_file
    when :RETURN
      return parse_return_statement
    when :BREAK
      return parse_break
    when :NEXT
      return parse_next
    when :COUNT
      return parse_count_loop
    when :DISPLAY
      return parse_display
    when :LET_USER_ASSIGN
      return parse_user_input
    when :IF
      return parse_if_statement
    when :WHILE
      return parse_while_loop
    when :FOR_EVERY
      return parse_for_loop
    when :DEFINE_TYPE
      return parse_type_definition
    when :DEFINE_FUNCTION
      return parse_function_definition
    when :DEFINE_UTILITY
      return parse_utility_definition
    when :TRY
      return self.parse_try_block
    else
      return self.parse_expression
    end
  end

  private

  def parse_try_block
    # This method parses a try/catch block
    
    position = @current_token.position
    self.move_cursor

    # Parse the try block
    try_block = self.parse_statements([:STOP, :CATCH, :ELSE])
    if try_block.is_a?(Error) then return try_block end

    # Parse catch blocks if there is any
    catch_blocks = Array.new
    while self.expect(:CATCH)
      self.move_cursor
      if self.expect(:TYPE_IDENTIFIER)

        # Parse the error type
        error = @current_token
        self.move_cursor

        # Parse the block
        error_block = self.parse_statements([:STOP, :CATCH, :ELSE])
        if error_block.is_a?(Error) then return error_block end

        catch_blocks << [error, error_block]
      else
        error = UnexpectedTokenError.new(secure_token, "type identifier", secure_position)
        error.add_suggestion("Provide the error you want to catch or use the \"else\" keyword to catch all errors")
        return error
      end
    end

    # Parse else block if there is any
    if self.expect(:ELSE)
      self.move_cursor
      else_block = self.parse_statements([:STOP])
      if else_block.is_a?(Error) then return else_block end
    else else_block = nil end

    if self.expect(:STOP)
      self.move_cursor
    else
      error = UnexpectedTokenError.new(secure_token, "stop", secure_position)
      error.add_suggestion("Try block must be closed with \"stop\" keyword.")
      return error
    end
    
    return TryNode.new(try_block, catch_blocks, else_block, position)
  end

  def parse_type_definition
    # This method parses a type definition
    
    position = @current_token.position
    self.move_cursor

    # A type identifier must start with A-Z
    if self.expect(:TYPE_IDENTIFIER)
      identifier = @current_token
      self.move_cursor
    else
      error = UnexpectedTokenError.new(secure_token, "type identifier", secure_position)
      error.add_suggestion("A type identifier is capitalized.")
      return error
    end

    # This is the arrays we the attributes and methods of the type will be stored
    attributes = []
    methods = []

    self.skip_newlines

    # If the keyword extend occurs, it means that the type should inherit from another
    # in that case the type identifier of the base type must be saved
    if self.expect(:EXTEND)
      self.move_cursor
      if self.expect(:TYPE_IDENTIFIER)
        parent = @current_token
        self.move_cursor
      else
        return UnexpectedTokenError.new(secure_token, "type identifier", secure_position)
      end
    else
      # In case the type should not inherit
      parent = nil
    end

    self.skip_newlines

    if self.expect(:DOC_COMMENT)
      doc_comment = @current_token.value
      self.move_cursor
    else
      doc_comment = "not documented"
    end
    if $CREATE_DOCS
      XMLWriter.new_class(identifier.value, doc_comment, parent)
    end

    self.skip_newlines

    # Only attributes and methods are allowed in the type definition
    # As long as there is no method definition attribute assignments
    # should be parsed
    if $CREATE_DOCS
      XMLWriter.open_attributes
    end
    
    while self.expect(:IDENTIFIER)
      attribute_name = @current_token.value
      attribute = parse_variable_assignment
      if attribute.is_a?(Error) then return attribute end
      attributes << attribute
      self.skip_newlines
      if self.expect(:DOC_COMMENT)
        doc_comment = @current_token.value
        self.move_cursor
      else
        doc_comment = "not documented"
      end
      if $CREATE_DOCS
        XMLWriter.add_attribute(attribute_name, doc_comment)
      end
      self.skip_newlines
    end

    if $CREATE_DOCS
      XMLWriter.close_attributes
      XMLWriter.open_methods
    end

    #self.skip_newlines

    # A type must contain at least one method, the constructor
    if not self.expect(:DEFINE_METHOD)
      error = UnexpectedTokenError.new(secure_token, "define method", secure_position)
      error.add_suggestion("Every type must have a constructor defined")
      return error
    end

    # Parse all methods of the type
    while self.expect(:DEFINE_METHOD)
      method = parse_function_definition
      if method.is_a?(Error) then return method end
      methods << method
      self.skip_newlines
    end

    if $CREATE_DOCS
      XMLWriter.close_methods
      XMLWriter.close_class
    end

    # A type definition should end with the keyword stop.
    if self.expect(:STOP)
      self.move_cursor
    else
      error = UnexpectedTokenError.new(secure_token, "stop", secure_position)
      error.add_suggestion("Type definition must be closed with \"stop\" keyword")
      return error
    end

    # If no errors, a TypeNode is returned
    return TypeNode.new(identifier, attributes, methods, parent, position)
  end

  def parse_utility_definition
    # This method is used to parse utilies, these are static types

    position = @current_token.position
    self.move_cursor
    
    if self.expect(:TYPE_IDENTIFIER)
      identifier = @current_token
      self.move_cursor
    else
      error = UnexpectedTokenError.new(secure_token, "type identifier", secure_position)
      error.add_suggestion("A type identifier is capitalized.")
      return error
    end

    self.skip_newlines

    if self.expect(:DOC_COMMENT)
      doc_comment = @current_token.value
      self.move_cursor
    else
      doc_comment = "not documented"
    end
    if $CREATE_DOCS
      XMLWriter.new_utility(identifier.value, doc_comment)
    end

    self.skip_newlines

    attributes = Array.new
    methods = Array.new

    if $CREATE_DOCS
      XMLWriter.open_attributes
    end

    while self.expect(:CONSTANT_IDENTIFIER)
      attribute_name = @current_token.value
      attribute = self.parse_constant_assignment
      if attribute.is_a?(Error) then return attribute end
      attributes << attribute
      self.skip_newlines
      if self.expect(:DOC_COMMENT)
        doc_comment = @current_token.value
        self.move_cursor
      else
        doc_comment = "not documented"
      end

      if $CREATE_DOCS
        XMLWriter.add_attribute(attribute_name, doc_comment)
      end
      self.skip_newlines
    end

    if $CREATE_DOCS
      XMLWriter.close_attributes
      XMLWriter.open_methods
    end

    while self.expect(:DEFINE_METHOD)
      method = self.parse_function_definition
      if method.is_a?(Error) then return method end
      methods << method
      self.skip_newlines
    end

    if $CREATE_DOCS
      XMLWriter.close_methods
      XMLWriter.close_utility
    end


    if self.expect(:STOP)
      self.move_cursor
    else
      error = UnexpectedTokenError.new(secure_token, "stop", secure_position)
      error.add_suggestion("Utility definition must be closed with \"stop\" keyword")
      return error
    end
    return UtilityNode.new(identifier, attributes, methods, position)
  end

  def parse_function_definition
    # This method parses functions and methods

    # First check if we are parsing a method or function
    type = @current_token.type
    position = @current_token.position
    self.move_cursor

    # The array where the parameters of the functions will be stored
    parameters = []

    # Save the name of the function
    if self.expect(:IDENTIFIER)
      identifier = @current_token
      self.move_cursor
    else
      return UnexpectedTokenError.new(@current_token, "identifier", secure_position)
    end

    if self.expect(:LEFT_PAREN)
      self.move_cursor
    else
      return UnexpectedTokenError.new(@current_token, "(", secure_position)
    end

    parameters = self.parse_parameters
    if parameters.is_a?(Error) then return parameters end

    if self.expect(:RIGHT_PAREN)
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, ")", secure_position)
    end

    self.skip_newlines
    if self.expect(:DOC_COMMENT)
      doc_comment = @current_token.value
      self.move_cursor
    else
      doc_comment = "not documented"
    end

    # Parse the body of the function
    body = parse_statements([:STOP])
    if body.is_a?(Error) then return body end
    if not self.expect(:STOP)
      return UnexpectedTokenError.new(secure_token, "stop", secure_position)
    end

    self.move_cursor

    if $CREATE_DOCS && type == :DEFINE_METHOD
      XMLWriter.add_method(identifier.value, doc_comment, parameters)
    end

    # If no errors, return a FunctionDefinitionNode
    return FunctionDefinitionNode.new(identifier, parameters, body, type, position)  
  end

  def parse_function_call
    # This method parses function and methods calls.
    
    position = @current_token.position
    arguments = []
    self.move_cursor

    # Parse the identifier as a expression, this is because methods should
    # be callable directly on numbers and text-objects aswell.
    identifier = self.parse_expression
    if identifier.is_a?(Error) then return identifier end

    if self.expect(:LEFT_PAREN)
      arguments = self.parse_arguments(:LEFT_PAREN, :RIGHT_PAREN)
      if arguments.is_a?(Error) then return arguments end
      # Assign a FunctionCallNode to the variable identifier
      # We do not return it yet so we can chain function and method-calls
      identifier = FunctionCallNode.new(identifier, arguments, position)
    end

    # If the next token is a dot, we should parse method calls.
    if self.expect(:DOT)
      while self.expect(:DOT)
        self.move_cursor
        if self.expect(:IDENTIFIER)
          method = @current_token
          self.move_cursor
        else
          return UnexpectedTokenError.new(secure_token, "identifier", secure_position)
        end
        arguments = self.parse_arguments(:LEFT_PAREN, :RIGHT_PAREN)
        if arguments.is_a?(Error) then return arguments end
        # Assign a MethodCallNode to identifier instead
        identifier = MethodCallNode.new(identifier, method, arguments, position)
      end
    end

    # If no errors, return the identifier, which can be a function, method or chained methods
    return identifier
  end

  def parse_lambda
    position = @current_token.position
    type = @current_token.type
    self.move_cursor
    
    parameters = self.parse_parameters
    if parameters.is_a?(Error) then return parameters end

    if self.expect(:PIPE)
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, "|", secure_position)
    end

    body = parse_expression
    if body.is_a?(Error) then return body end
    body = ReturnNode.new(body, position)
    body = StatementsNode.new([body], position)

    if self.expect(:PIPE)
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, "|", secure_position)
    end
    
    return FunctionDefinitionNode.new(nil, parameters, body, type, position)
  end
      

  def parse_parameters
    # This variable keeps track if the variable should be passed as
    # a copy or as a reference
    parameters = Array.new
    copy = false

    self.skip_newlines
    
    if self.expect(:COPY)
      copy = true
      self.move_cursor
    end

    # Save all the parameters of the function
    if self.expect(:IDENTIFIER)
      parameters << [@current_token, copy]
      self.move_cursor
      self.skip_newlines
      while self.expect(:COMMA)
        self.move_cursor
        self.skip_newlines
        copy = false
        if self.expect(:COPY)
          copy = true
          self.move_cursor
        end
        if self.expect(:IDENTIFIER)
          # The parameter is saved as an array with the name of the parameter
          # and a boolean that tells if the parameter should be copied or not
          parameters << [@current_token, copy]
          self.move_cursor
        else
          error = UnexpectedTokenError.new(secure_token, "identifier", secure_position)
          error.add_suggestion("One comma to much?")
          return error
        end
        self.skip_newlines
      end
    end
    return parameters
  end

  def parse_return_statement
    # This method parses a return statement
    
    position = @current_token.position
    self.move_cursor

    # If there is a newline, no return value has been provided
    if self.expect(:NEWLINE) || self.expect(:STOP)
      return ReturnNode.new(nil, position)
    else
      # Otherwise the return value should be parsed
      result = parse_logical_expression
      if result.is_a?(Error) then return result end
      return ReturnNode.new(result, position)
    end
  end

  def parse_while_loop
    # This method parses a while-loop
    
    position = @current_token.position
    self.move_cursor

    # Parse the condition of the while-loop
    condition = self.parse_expression
    if condition.is_a?(Error) then return condition end

    # Parse the block of the while-loop
    block = self.parse_statements([:STOP])
    if block.is_a?(Error) then return block end
    if self.expect(:STOP)
      self.move_cursor
    else
      error = UnexpectedTokenError.new(secure_token, "stop", secure_position)
      error.add_suggestion("While loop must be closed with \"stop\" keyword.")
      return error
    end

    # Return the WhileNode
    return WhileNode.new(condition, block, position)
  end

  def parse_count_loop
    # This method parses a count loop
    
    position = @current_token.position
    self.move_cursor

    # Save the identifier
    if self.expect(:IDENTIFIER)
      identifier = @current_token
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, "identifier", secure_position)
    end
    
    if self.expect(:FROM)
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, "from", secure_position)
    end

    # Parse the starting number
    from = parse_logical_expression
    if from.is_a?(Error) then return from end
    
    if self.expect(:TO)
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, "to", secure_position)
    end

    # Parse the ending number
    to = parse_logical_expression
    if to.is_a?(Error) then return from end

    # Parse the body of the loop
    body = parse_statements([:STOP])
    if body.is_a?(Error) then return body end
    
    if self.expect(:STOP)
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, "stop", secure_position)
    end
    return CountLoopNode.new(identifier, from, to, body, position)   
  end

  def parse_for_loop
    # This method parses a for loop
    
    position = @current_token.position
    self.move_cursor

    # In a for loop, it is possible to ask for a copy of the list item
    if self.expect(:COPY)
      copy = true
      self.move_cursor
    end
    
    # Save the identifier 
    if self.expect(:IDENTIFIER)
      identifier = @current_token
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, "identifier", secure_position)
    end
    
    if self.expect(:IN)
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, "in", secure_position)
    end

    # Parse the list that should be iterated
    list = parse_logical_expression
    if list.is_a?(Error) then return list end

    # Parse the body of the loop
    body = parse_statements([:STOP])
    if body.is_a?(Error) then return body end
    
    if self.expect(:STOP)
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, "stop", secure_position)
    end
    return ForLoopNode.new(identifier, list, body, copy, position)   
  end

  def parse_break
    # This method detects a break
    position = @current_token.position
    self.move_cursor
    return BreakNode.new(position)
  end

  def parse_next
    # This method detects when to skip a loop iteration
    position = @current_token.position
    self.move_cursor
    return NextNode.new(position)
  end

  def parse_if_statement
    # This method parses an if-statement
    
    position = @current_token.position

    # This array will store the branches of the if-statement
    # This means if-branches and else if-branches
    branches = Array.new
    self.move_cursor

    # Parse the condition
    condition = parse_logical_expression
    if condition.is_a?(Error) then return condition end
    
    if self.expect(:THEN)
      self.move_cursor
      # Save the position of this branch
      branch_position = @current_token.position

      # Parse the body of the statement
      body = parse_statements([:ELSE_IF, :ELSE, :STOP])
      if body.is_a?(Error) then return body end

      # Add a IfBranchNode to the array
      branches << IfBranchNode.new(condition, body, branch_position)
    else
      error = UnexpectedTokenError.new(@current_token, "then", position)
      error.add_suggestion("Keyword \"then\" must be used after the condition")
      return error
    end

    # While there is else if statements, we do the same with them
    while self.expect(:ELSE_IF)
      self.move_cursor
      
      condition = parse_logical_expression
      if condition.is_a?(Error) then return condition end
      
      if @current_token and @current_token.type == :THEN
        branch_position = @current_token.position
        self.move_cursor
        block = parse_statements([:ELSE_IF, :ELSE, :STOP])
        branches << IfBranchNode.new(condition, block, branch_position)
      end
    end

    # If there is an else-block, we parse that aswell.
    if self.expect(:ELSE)
      self.move_cursor
      else_block = parse_statements([:STOP])
      if_statement = IfStatementNode.new(branches, else_block, position)
    else
      if_statement = IfStatementNode.new(branches, nil, position)
    end
    if @current_token and @current_token.type == :STOP
      self.move_cursor
      return if_statement
    else
      error = UnexpectedTokenError.new(secure_token, "stop", secure_position)
      error.add_suggestion("If statements must be closed with keyword \"stop\".")
      return error
    end
  end

  def parse_display
    # This method is used for parsing the built in display function.
    
    position = @current_token.position
    self.move_cursor

    # Parse the value that should be printed to the terminal
    display_value = parse_logical_expression
    if display_value.is_a?(Error) then return display_value end
    return DisplayNode.new(display_value, position)
  end

  def parse_user_input
    # This method is used for parsing input
    
    position = @current_token.position
    self.move_cursor
    
    if self.expect(:IDENTIFIER)
      # Save the identifier
      identifier_token = @current_token
      self.move_cursor
      return UserInputNode.new(identifier_token, position)
    else
      UnexpectedTokenError.new(secure_token, "end of line", secure_position)
    end
  end

  def parse_variable_assignment
    # This method if used for parsing variable assigment

    # Save the name of the identifier
    identifier = @current_token

    # We can skip two times since we checked for the assignment token before
    self.move_cursor
    self.move_cursor

    # Parse the value that should be assigned to the variable
    value = self.parse_expression
    if value.is_a?(Error) then return value end
    
    return VariableAssignmentNode.new(identifier, value) 
  end

  def parse_constant_assignment
    identifier = @current_token
    self.move_cursor

    if self.expect(:ASSIGNMENT)
      self.move_cursor
    else
      UnexpectedTokenError.new(secure_token, "=", secure_position)
    end

    value = self.parse_logical_expression
    if value.is_a?(Error) then return value end
    return ConstantAssignmentNode.new(identifier, value)
  end
  
  def parse_index_access(identifier)
    # This method is used for parsing an index access. This can be for lists, text or dictionaries
    
    position = identifier.position

    # While loop is used because the operator should be able to chain
    while self.expect(:LEFT_SQUARE)
      self.move_cursor

      # Parse the index that should be accessed
      index = self.parse_expression
      if index.is_a?(Error) then return index end
      
      if self.expect(:RIGHT_SQUARE)
        self.move_cursor
      else
        return UnexpectedTokenError.new(@current_token, "]", position)
      end

      # If the next token is an assignment node, we should not create a new index access node.
      if self.expect(:ASSIGNMENT) then break end
      identifier = IndexAccessNode.new(identifier, index, position)
    end

    # If the next token is assignment, we should instead create an index assignment node
    if self.expect(:ASSIGNMENT)
      self.move_cursor
      new_value = self.parse_logical_expression
      if new_value.is_a?(Error) then return new_value end
      return IndexAssignmentNode.new(identifier, index, new_value, position)
    end
    return identifier
  end
  
  def parse_import
    # This method is used for parsing import statement
    
    position = @current_token.position
    self.move_cursor

    # Parse the filename
    filename = self.parse_logical_expression
    if filename.is_a?(Error) then return filename end
    result = ImportNode.new(filename, position)

    if $CREATE_DOCS
      DocCreator.create(result)
    end

    return result
  end

  def parse_load_file
    # This method is used for file opening statements
    
    position = @current_token.position
    self.move_cursor

    # Parse the filename
    filename = self.parse_logical_expression
    if filename.is_a?(Error) then return filename end

    if self.expect(:INTO) then self.move_cursor
    else
      return UnexpectedTokenError.new(secure_position, "into", secure_position)
    end

    if self.expect(:IDENTIFIER)
      identifier = @current_token
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_position, "identifier", secure_position)
    end
    return OpenFileNode.new(filename, identifier, position)
  end

  def parse_factor
    # This method is used to parse factors
    
    token = @current_token
    position = @current_token.position
    
    case @current_token.type
    when :NOT
      result = self.parse_unary_operation([:NOT]) {self.parse_expression}
    when :CREATE
      result = self.parse_type_init
    when :PIPE
      result = self.parse_lambda
    when :ADDITION
      result = self.parse_unary_operation(@expression_operators) { self.parse_factor }
    when :SUBTRACTION
      result = self.parse_unary_operation(@expression_operators) { self.parse_factor }
    when :CALL
      result = self.parse_function_call
    when :INT
      self.move_cursor
      result = NumericNode.new(token)
    when :FLOAT
      self.move_cursor
      result = NumericNode.new(token)
    when :BOOLEAN
      self.move_cursor
      result = BooleanNode.new(token)
    when :NULL
      self.move_cursor
      result = NullNode.new(token)
    when :TEXT
      self.move_cursor
      result = TextNode.new(token)
    when :LEFT_PAREN
      self.move_cursor
      result = self.parse_logical_expression
      if result.is_a?(Error) then return result end
      if self.expect(:RIGHT_PAREN) then self.move_cursor
      else
        return UnexpectedTokenError.new(@current_token, ")", position)
      end
    when :LEFT_SQUARE
      result = self.parse_new_list
    when :LEFT_CURL
      result = self.parse_dictionary
      if result.is_a?(Error) then return result end
    when :CONSTANT_IDENTIFIER
      result = parse_type_identifier
    when :TYPE_IDENTIFIER
      result = parse_type_identifier
    when :IDENTIFIER
      result = VariableAccessNode.new(@current_token)
      if result.is_a?(Error) then return result end
      self.move_cursor

      while self.expect(:AT)
        self.move_cursor
        if self.expect(:IDENTIFIER) || self.expect(:CONSTANT_IDENTIFIER)
          identifier = @current_token
          self.move_cursor
        else
          return UnexpectedTokenError.new(
                   secure_token, "identifier, constant identifier", secure_position)
        end
        result = AttributeAccessNode.new(result, identifier, position)
      end
    else
      return UnexpectedTokenError.new(@current_token, "Number, , +, (", position)
    end
    if result.is_a?(Error) then return result end

    if self.expect(:LEFT_SQUARE)
      result = self.parse_index_access(result)
    end
    return result
  end

  def parse_identifier
    identifier = @current_token
    self.move_cursor
    if self.expect(:LEFT_SQUARE) then return parse_index_access(identifier) end
    return VariableAccessNode.new(identifier)
  end

  def parse_type_identifier
    position = @current_token.position
    
    result = @current_token
    self.move_cursor
    result = VariableAccessNode.new(result)
    if not self.expect(:AT) then return result end
                        
    while self.expect(:AT)
      self.move_cursor
      if self.expect(:IDENTIFIER) or self.expect(:CONSTANT_IDENTIFIER)
        identifier = @current_token
        self.move_cursor
      else
        return UnexpectedTokenError.new(secure_token, "identifier, constant", secure_position)
      end
      result = AttributeAccessNode.new(result, identifier, position)
    end
    return result
  end

  def parse_new_list
    position = @current_token.position
    arguments = self.parse_arguments(:LEFT_SQUARE, :RIGHT_SQUARE)
    if arguments.is_a?(Error) then return arguments end
    return ListNode.new(arguments, position)
  end

  def parse_attribute_access
    return self.parse_binary_operation([:AT]) {self.parse_factor}
  end

  def parse_exponent
    return self.parse_binary_operation(@exponent_operator, :right) { self.parse_attribute_access }
  end

  def parse_term
    return self.parse_binary_operation(@term_operators) { self.parse_exponent }
  end

  def parse_arithmetic_expression
    return self.parse_binary_operation(@expression_operators) { self.parse_term }
  end

  def parse_boolean_expression
    return self.parse_binary_operation(@boolean_operators) { self.parse_arithmetic_expression }
  end

  def parse_expression
    if self.expect(:IDENTIFIER) || self.expect(:CONSTANT_IDENTIFIER)
      if @tokens[@position+1] && @tokens[@position+1].type == :ASSIGNMENT
        return self.parse_variable_assignment
      end
    end
    return self.parse_binary_operation(@assignment_operators, :right) {self.parse_logical_expression }
  end

  def parse_logical_expression
    return self.parse_binary_operation(@logical_operators) { self.parse_boolean_expression }
  end

  def parse_binary_operation(operators, associativity = :left, &block)
    left_node = block.call
    if left_node.is_a?(Error) then return left_node end
    
    if associativity == :left
      while @current_token and operators.include?(@current_token.type)
        operator = @current_token
        self.move_cursor
        if operators.include?(:AT)
          left_node = BinaryOperationNode.new(left_node, operator, secure_token)
          self.move_cursor
        else
          right_node = block.call
          if right_node.is_a?(Error) then return right_node end 
          left_node = BinaryOperationNode.new(left_node, operator, right_node)
        end
      end
    elsif associativity == :right
      if @current_token and operators.include?(@current_token.type)
        operator = @current_token
        self.move_cursor
        right_node = parse_binary_operation(operators, associativity, &block)
        if right_node.is_a?(Error) then return right_node end
        left_node = BinaryOperationNode.new(left_node, operator, right_node)
      end
    end
    
    return left_node
  end

  def parse_unary_operation(operators, &block)
    operator = @current_token
    self.move_cursor
    right_node = block.call
    if right_node.is_a?(Error) then return right_node end
    return UnaryOperationNode.new(right_node, operator)
  end

  def parse_dictionary
    position = @current_token.position
    values = []
    self.move_cursor
    if self.expect(:RIGHT_CURL)
      self.move_cursor
      return DictNode.new(values, position)
    end

    self.skip_newlines
    
    key = self.parse_logical_expression
    if key.is_a?(Error) then return key end
    if not self.expect(:COLON)
      return UnexpectedTokenError.new(secure_token, ":", secure_position)
    else
      self.move_cursor
    end
    value = self.parse_logical_expression
    if value.is_a?(Error) then return key end
    values << [key, value]

    self.skip_newlines
    
    while self.expect(:COMMA)
      self.move_cursor
      self.skip_newlines
      key = self.parse_logical_expression
      if key.is_a?(Error) then return key end
      if not self.expect(:COLON)
        return UnexpectedTokenError.new(secure_token, ":", secure_position)
      else
        self.move_cursor
      end
      value = self.parse_logical_expression
      if value.is_a?(Error) then return key end
      values << [key, value]
      self.skip_newlines
    end
    if not self.expect(:RIGHT_CURL)
      return UnexpectedTokenError.new(secure_token, "}", secure_position)
    end
    self.move_cursor
    return DictNode.new(values, position)
  end

  def parse_type_init
    position = @current_token.position
    self.move_cursor

    if self.expect(:TYPE_IDENTIFIER)
      identifier = @current_token
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_position, "type identifier", secure_position)
    end

    arguments = self.parse_arguments(:LEFT_PAREN, :RIGHT_PAREN)
    if arguments.is_a?(Error) then return parameters end

    return TypeInitNode.new(identifier, arguments, position)
  end

  def parse_arguments(start, stop)
    arguments = []
    if self.expect(start)
      self.move_cursor
    else
      return UnexpectedTokenError.new(secure_token, start.to_s.downcase, secure_position)
    end
    if not self.expect(stop)
      self.skip_newlines
      if (argument = parse_logical_expression).is_a?(Error) then return argument end
      arguments << argument
    end

    self.skip_newlines
    
    while self.expect(:COMMA)
      self.move_cursor
      self.skip_newlines
      argument = parse_logical_expression
      if argument.is_a?(Error) then return arguments end
      arguments << argument
      self.skip_newlines
    end

    if self.expect(stop)
      self.move_cursor
    else
      error = UnexpectedTokenError.new(secure_token, stop.to_s.downcase, secure_position)
      error.add_suggestion("Argument list must be closed with #{stop.to_s.downcase}")
      return error
    end
    return arguments
  end

  def secure_token
    if @current_token then return @current_token end
    token = @tokens[@position-1]
    token.value = "end of file"
    return token
  end

  def secure_position
    if @current_token then return @current_token.position end
    @tokens[@position-1].position
  end

  def move_cursor
    @position += 1
    if @position < @tokens.length then @current_token = @tokens[@position] else @current_token = nil end
  end
  
  def expect(token_type)
    if @current_token and @current_token.type == token_type
      return true
    end
    return false
  end

  def skip_newlines
    while self.expect(:NEWLINE)
      self.move_cursor end
  end
end
