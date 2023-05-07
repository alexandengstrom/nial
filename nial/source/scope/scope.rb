# coding: utf-8

require_relative "../algorithms/algorithms"
require_relative "../datatypes/text"
require_relative "../datatypes/builtin_utilities/system_manager"
require_relative "../datatypes/builtin_utilities/io_manager"
require_relative "../datatypes/builtin_utilities/time_manager"
require_relative "../datatypes/builtin_utilities/rand_op_manager"
require_relative "../datatypes/builtin_utilities/file_manager"
require_relative "../datatypes/builtin_utilities/algo_manager"
require_relative "../datatypes/builtin_types/database"
require_relative "../datatypes/builtin_types/time_stamp"
require_relative "../datatypes/builtin_types/canvas/canvas"

##
# Represents a Scope in the Nial language. This scope is used as global scope,
# inside loops and inside control structures.
class Scope
  attr_accessor :parent, :variables, :type_templates, :name, :position

  ##
  # Creates a new scope. +parent+ will be set to nil if no parent is provided.
  # This means this is the global scope, all other scopes will have a parent.
  def initialize(name, parent, position)
    @name = name
    @parent = parent
    @variables = Hash.new
    @position = position
    @type_templates = []
    @included_files = Array.new
    @DEBUG = false

    if not @parent then self.setup_global_scope end
  end

  ##
  # This method gets called if the global scope is being created.
  # The purpose of this is to include the standard library.
  def setup_global_scope
    SystemManager.setup()
    @variables["SystemManager"] = SystemManager
    @variables["IOManager"] = IOManager
    @variables["FileManager"] = FileManager
    @variables["RandOpManager"] = RandOpManager
    @variables["TimeManager"] = TimeManager
    @variables["AlgoManager"] = AlgoManager

    @type_templates << Database
    @type_templates << Canvas
    @type_templates << TimeStamp
  end

  ##
  # This method gets called when the VariableNotDefined exception occurs.
  # The method will search for a variable with a simular name to help
  # the user with typos.
  def find_simular(identifier, best_match = [nil, 0])
    current_match, current_score = self.find_closest_match(identifier)
    if current_score > best_match[1]
      best_match[0] = current_match
      best_match[1] = current_score
    end

    if @parent
      return @parent.find_simular(identifier, best_match)
    elsif best_match[1] > 0.7
      return best_match[0]
    else
      return false
    end
  end

  # def set_constant(identifier, value)
  #   return "ERROR"
  # end

  ##
  # Adds variables to the current scope as key-value pairs. This method
  # is used when matching parameters with arguments in function calls.
  def add_pairs(arguments, parameters)
    if arguments.length == parameters.length
      arguments.each_with_index {|argument, index|
        parameter = parameters[index][0]
        if parameters[index][1]
          argument = argument.copy(self, position)
        end
        @variables[parameter.value] = argument
      }
    end
  end

  ##
  # Controls if a file has been included in the current scope.
  # If a file is already included it should not be included again.
  def file_is_included(filename)
    if @included_files.include?(filename)
      return true
    elsif not @parent
      @included_files << filename
      return false
    else
      return @parent.file.is_included(filename)
    end
  end

  ##
  # Returns a user defined Type if its defined. Otherwise returns
  # TypeNotDefined exception.
  def get_type(type, scope, position)
    @type_templates.each {|current_type|
      if current_type.name == type
        return current_type
      end
    }

    if parent == nil
      return TypeNotDefined.new(type, scope, position)
    end
    return @parent.get_type(type, scope, position)
    
  end

  ##
  # Creates a new variable. The method will first look if the variable
  # if already defined in this scope or in one of the parent scopes. If the
  # variable exists in another scope the value should be updated in that scope
  # and not in this scope. If the variable does not exist it will be created
  # in this scope. The method will also make sure a constant is not redefined.
  def set_variable(identifier, value)
    current_value = self.get_variable(identifier)
    if current_value.is_a?(Error) || !@parent
      potential_error = self.constant_defined(identifier)
      if potential_error.is_a?(Error) then return potential_error end
      if identifier.type == :CONSTANT_IDENTIFIER then value.make_constant end
      @variables[identifier.value] = value
    else
      potential_error = self.value_is_constant(current_value, identifier)
      if potential_error.is_a?(Error) then return potential_error end
      self.set_variable_in_parent(identifier, value)
    end
  end



  ##
  # Gets called if a variable should be set in a parent scope.
  def set_variable_in_parent(identifier, value)
    if @variables.has_key?(identifier.value) || !@parent
      @variables[identifier.value] = value
    else
      @parent.set_variable_in_parent(identifier, value)
    end
  end

  ##
  # Returns a variable or a VariableNotDefined exception.
  def get_variable(identifier)
    if @variables.has_key?(identifier.value)
      return @variables[identifier.value]
    elsif @parent != nil
      return @parent.get_variable(identifier)
    else
      return VariableNotDefined.new(identifier, self, identifier.position)
    end
  end

  ##
  # The method is called by when an runtime error occurs to create a traceback.
  def to_string(traceback="")
    traceback += "In file #{@position.file}, line #{@position.line}, column #{@position.column} in #{@name}" + "\n"
    check = traceback.split("\n")
    if check.length > 4 && check[-1] == check[-2] && check[-1] == check[-3] && check[-1] == check[-4]
      traceback += "and many more..." + "\n"
      return traceback
    end
    if @parent then return parent.to_string(traceback) else return traceback end
  end

  private

  def find_global_scope
    parent = @parent
    while parent and parent.parent != nil
      parent = parent.parent
    end
    return parent
  end

  ##
  # Returns true if the identifier exists, else false.
  def exists?(identifier)
    return !self.get_variable(identifier).is_a?(Error)
  end
  
  def constant_defined(identifier)
    if self.exists?(identifier) && identifier.type == :CONSTANT_IDENTIFIER
      error = ConstantAlreadyDefined.new(
        "Constant #{identifier.value} is already defined, can not redefine a constant.",
        self, identifier.position)
      if identifier.value != identier.value.upcase
        error.add_suggestion("All attributes of a constant Type becomes constant.")
      end
      return error
    end
  end

  def value_is_constant(value, identifier)
    if value.constant
      error = ConstantAlreadyDefined.new(
        "Constant #{identifier.value} is already defined, can not redefine a constant.",
        self, identifier.position)
      if identifier.value != identifier.value.upcase
        error.add_suggestion("All attributes of a constant Type becomes constant.")
      end
      return error
    end
  end
  
  def find_closest_match(identifier)
    best_match, best_score = nil, 0
    
    @variables.each_pair { |key, value|
      result = Algorithms.levenshtein_distance(identifier.value, key)
      if result > best_score

        best_match = key
        best_score = result
      end
    }
    return best_match, best_score
  end
end

