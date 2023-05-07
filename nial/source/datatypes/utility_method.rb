require_relative "type_method"

##
# Represents a Utility method in the Nial language.
class UtilityMethod < TypeMethod

  ##
  # Creates a new UtilityMethod
  def initialize(name, parameters, block)
    super(name, parameters, block)
  end

  ##
  # Gets called when the UtilityMethod is called.
  def call(arguments, scope, position)
    method_scope = UtilityScope.new(@name, scope, position)
    method_scope.add_pairs(arguments, @parameters)

    if @parameters.length != arguments.length
      return WrongNumberOfArguments.new(arguments.length, @parameters.length, scope, position)
    end
    
    begin
      return Interpreter.evaluate(@block, method_scope)
    rescue SystemStackError => e
      return ToMuchRecursionError.new("Too much recursion", method_scope, position)
    end
  end
end
