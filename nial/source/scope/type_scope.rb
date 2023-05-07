require_relative "scope"
require_relative "../exceptions/error"

##
# Represents the scope of a Type object in the Nial language.
class TypeScope < Scope
  attr_accessor :variables

  ##
  # Creates a new TypeScope.
  def initialize(name, parent, position)
    super(name, parent, position)
  end

  ##
  # Gets called if the user initializes an instance of this Type
  # as constant. Will make all variables in the TypeScope constants.
  def make_constant
    @variables.each_pair { |key, value|
      if key != "self" then value.make_constant end
    }

    if @parent && @parent.is_a?(TypeScope)
      @parent.make_constant
    end
  end

  ##
  # Adds self to the scope.
  def add_self(object)
    @variables["self"] = object
  end

  ##
  # Searches for operator overloading. If a operator has been overloaded the
  # method is returned, else the MethodMissing exception is returned.
  def get_operator(operator, scope, position)
    @variables.each_pair {|key, value|
      if key == operator then return value end
    }

    if @parent.is_a?(TypeScope)
      return @parent.get_operator(operator, scope, position)
    else
      return MethodMissing.new("Method missing, #{scope.name} has no method named #{operator}", self, position)
    end
  end

  ##
  # Set a variable. A variable is always set in the current scope.
  def set_variable(identifier, value)
    @variables[identifier.value] = value
    return value
  end

  ##
  # Get a variable. Will look for variables in the current scope and in all types
  # in inherits from. If not found it will look in the global scope.
  def get_variable(identifier)
    if @variables.has_key?(identifier.value)
      return @variables[identifier.value]
    elsif [TypeScope, MethodScope].include?(@parent.class)
      return @parent.get_variable(identifier)
    else
      return super(identifier)
    end
  end

  ##
  # Returns true if the method is defined, else false.
  def has_method(method)
    @variables.each_pair {|key, value|
      if key == method then return true end
    }
    return false
  end

  ##
  # Returns the method requested or the MethodMissing exception.
  def get_method(method)
    @variables.each_pair {|key, value|
      if key == method then return value end
    }
    return MethodMissing.new("Method missing, #{@name} has no method named \"constructor", self, @position)
  end

  ##
  # Creates a copy of the scope. This is called every time a new instance of
  # a type is initialized.
  def copy(scope, position)
    new_values = Hash.new
    @variables.each_pair {|key, value|
      new_values[key] = value.copy(scope, position)
    }

    if @parent.is_a?(TypeScope)
      new_parent = @parent.copy(scope, position)
    else
      new_parent = @parent
    end
    
    new_scope = TypeScope.new("#{name}", new_parent, position)
    new_scope.variables = new_values
    return new_scope
  end

  ##
  # This method gets called when the keyword parent is used inside a method.
  # Will return the same method from the parent type or an exception.
  def get_parent(layers, method_name)
    if layers == 0
      return self.get_method(method_name)
    else
      @parent.get_parent(layers-1, method_name)
    end
  end
end


