# coding: utf-8
#require_relative "../interpreter/interpreter"
require_relative "../scope/function_scope"
require_relative "null"

##
# Represents a function in the Nial language.
#
# ==== Attributes
# +name+ +parameters+ +block+
class Function < Null
  attr_accessor :parameters, :name, :block

  ##
  # Creates a new function. Takes the function name, the parameters it expects and a block of code as parameters.
  def initialize(name, parameters, block)
    super("<function>")
    @name = name
    @parameters = parameters
    @block = block
  end

  ##
  # This method gets called when the function is called.
  def call(arguments, scope, position)
    function_scope = FunctionScope.new(@name, scope, position)
    function_scope.add_pairs(arguments, @parameters)

    if @parameters.length != arguments.length
      return WrongNumberOfArguments.new(arguments.length, @parameters.length, scope, position)
    end
    
    begin
      return Interpreter.evaluate(@block, function_scope)
    rescue SystemStackError
      return ToMuchRecursionError.new("Too much recursion", function_scope, position)
    end
  end

  ##
  # The method gets called when the program expects a function object. The function object will return itself.
  def convert_to_function(scope, postiion)
    return self
  end

  ##
  # Return itself.
  def copy(scope, position)
    return self
  end

  ##
  # The method is called when the user wants to display a function to the terminal
  def display(_, _)
    return Text.new("<#{self.class} at #{self.to_s.split(":")[1]}")
  end
end
