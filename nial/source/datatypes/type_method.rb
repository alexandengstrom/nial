require_relative "null"
require_relative "../scope/method_scope"

##
# Represents a method in the Nial language.
class TypeMethod < Null
  attr_accessor :parameters, :name, :block

  ##
  # Creates a new method. Stores a name, the parameters and a block of code.
  def initialize(name, parameters, block)
    super("<method>")
    @name = name
    @parameters = parameters
    @block = block
  end

  ##
  # Gets called when the method is called.
  def call(arguments, scope, position)
    method_scope = MethodScope.new(@name, scope, position)
    method_scope.add_pairs(arguments, @parameters)

    if @parameters.length != arguments.length
      return WrongNumberOfArguments.new(arguments.length, @parameters.length, scope, position)
    end
    
    begin
      return Interpreter.evaluate(@block, method_scope)
    rescue SystemStackError
      return ToMuchRecursionError.new("Too much recursion", method_scope, position)
    end
  end

  ##
  # Returns itself
  def copy(scope, position)
    return self
  end

  ##
  # Gets called when the user wants to output a TypeMethod to the terminal.
  def display(_, _)
    return Text.new("<#{self.class} at #{self.to_s.split(":")[1][0..-2]}>")
  end
end
