require_relative "scope"
require_relative "../exceptions/error"

##
# Represents the scope inside a Method in the Nial language.
class MethodScope < Scope

  ##
  # Creates a new MethodScope.
  def initialize(name, parent, position)
    super(name, parent, position)
  end

  ##
  # This method just tunnels the request to the parent.
  def get_parent(layers, method_name)
    return @parent.get_parent(layers, method_name)
  end

  ##
  # Returns the variable requested or a VariableNotDefined exception.
  def get_variable(identifier)
    if identifier.value == "parent"
      layers = self.find_layers_to_parent
      return self.get_parent(layers, @name)
    end
    
    if @variables.has_key?(identifier.value)
      return @variables[identifier.value]
    else
      parent = @parent
      while parent and parent.parent != nil
        if parent.is_a?(TypeScope)
          return parent.get_variable(identifier)
        end
        parent = parent.parent
      end
      if parent.variables.has_key?(identifier.value)
        return parent.variables[identifier.value]
      else
        return VariableNotDefined.new(identifier, self, identifier.position)
      end
    end
  end

  private

  def find_layers_to_parent
    counter = 1
    parent = @parent
    method_name = @name
    while parent.name == method_name
      counter += 1
      parent = parent.parent
    end
    return counter
  end
end
