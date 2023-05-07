require_relative "scope"
require_relative "../exceptions/error"

##
# Represents a scope inside a function in the Nial language.
class FunctionScope < Scope

  ##
  # Creates a new FunctionScope.
  def initialize(name, parent, position)
    super(name, parent, position)
  end

  ##
  # Searches for a simular variable in the current scope and then jumps
  # the the global scope to search.
  def find_simular(identifier, best_match = [nil, 0])
    current_match, current_score = self.find_closest_match(identifier)
    if current_score > best_match[1]
      best_match[0] = current_match
      best_match[1] = current_score
    end

    global_scope = self.find_global_scope
    return global_scope.find_simular(identifier, best_match)
  end

  ##
  # Returns the variable identifier or the VariableNotDefined exception.
  def get_variable(identifier)  
    if @variables.has_key?(identifier.value)
      return @variables[identifier.value]
    else
      global_scope = self.find_global_scope
      if global_scope.variables.has_key?(identifier.value)
        return global_scope.variables[identifier.value]
      else
        return VariableNotDefined.new(identifier, self, identifier.position)
      end
    end
  end

  ##
  # Sets a new variable. In a FunctionScope its not allowed to set a variable
  # in a parent scope.
  def set_variable(identifier, value)
    if identifier.type == :CONSTANT_IDENTIFIER && self.exists?(identifier)
      return ConstantAlreadyDefined.new(identifier, self, identifier.position)
    end
    @variables[identifier.value] = value
    return value
  end
end
