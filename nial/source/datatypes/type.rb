# coding: utf-8
#require_relative "../interpreter/interpreter"
require_relative "null"

##
# Represents a user defined class called Type in the Nial language
class Type < Null
  attr_accessor :scope, :name

  ##
  # Creates a new Type.
  def initialize(name, scope)
    super("<type>")
    @name = name
    @scope = scope
    @scope.add_self(self)
  end

  ##
  # Makes the object constant by making all attributes in the Type constants.
  def make_constant
    @constant = true
    @scope.make_constant
  end

  ##
  # Gets called when the user wants to output the Type object to the terminal.
  # If the user has defined a method named display, that method will be called.
  # Otherwise the name and memory address will be displayed.
  def display(scope, position)
    overloaded = @scope.get_operator("display", scope, position)
    if overloaded.is_a?(Error)
      return Text.new("<#{@name} at #{self.to_s.split(":")[1]}")
    end
    return overloaded.call([], @scope, position)
  end

  ##
  # Returns a method of the Type object.
  def get_method(method, scope, position)
    return @scope.get_variable(method)
  end

  ##
  # Returns a attribute of the Type object.
  def get_attribute(attribute, scope, position)
    attribute = @scope.get_variable(attribute)
    if attribute.is_a?(Error) then return attribute end
    return attribute.copy(scope, position)
  end

  ##
  # Returns the name of the Type object.
  def type(scope, position)
    return Text.new("#{@name}")
  end

  ##
  # Gets called if the operator + is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def addition(other, scope, position)
    overloaded = @scope.get_operator("addition", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator - is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def subtraction(other, scope, position)
    overloaded = @scope.get_operator("subtraction", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator / is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def division(other, scope, position)
    overloaded = @scope.get_operator("division", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator * is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def multiplication(other, scope, position)
    overloaded = @scope.get_operator("multiplication", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator % is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def modulo(other, scope, position)
    overloaded = @scope.get_operator("modulo", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator == is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def equals(other, scope, position)
    overloaded = @scope.get_operator("equals", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator != is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def not_equals(other, scope, position)
    overloaded = @scope.get_operator("not_equals", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator > is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def greater_than(other, scope, position)
    overloaded = @scope.get_operator("greater_than", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator < is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def less_than(other, scope, position)
    overloaded = @scope.get_operator("less_than", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator >= is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def equals_or_greater_than(other, scope, position)
    overloaded = @scope.get_operator("equals_or_greater_than", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator <= is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def equals_or_less_than(other, scope, position)
    overloaded = @scope.get_operator("equals_or_less_than", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator += is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def addition_assignment(other, scope, position)
    overloaded = @scope.get_operator("addition_assignment", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator -= is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def subtraction_assignment(other, scope, position)
    overloaded = @scope.get_operator("subtraction_assignment", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator /= is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def division_assignment(other, scope, position)
    overloaded = @scope.get_operator("division_assignment", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Gets called if the operator *= is being used when a Type object is the first operand.
  # If the user has overloaded the operator, that method gets called. Otherwise the
  # superclass is called.
  def multiplication_assignment(other, scope, position)
    overloaded = @scope.get_operator("addition_assignment", scope, position)
    if overloaded.is_a?(Error)
      return super(other, scope, position)
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # This method lets the user override the convert_to_list method in the superclass. This makes it possible to use
  # the object as iterator in for-loops. If the user has overridden the method, it must also return a List object.
  # Otherwise a ConversionError exception will be returned.
  def convert_to_list(scope, position)
    overloaded = @scope.get_operator("convert_to_list", scope, position)
    if overloaded.is_a?(Error)
      return super(scope, position)
    end
    result = overloaded.call([], @scope, position)
    if result.is_a?(Error) then return result end
    if not result.is_a?(List)
      return ConversionError.new("Conversion error, overridden method convert_to_list in type #{@name} returns #{result.class} and not List.", scope, position)
    end
    return result
  end

  ##
  # This method lets the user override the convert_to_text method in the superclass. This prevents error everytime
  # a Text object is required. If the user has overridden the method, it must also return a Text object.
  # Otherwise a ConversionError exception will be returned.
  def convert_to_text(scope, position)
    overloaded = @scope.get_operator("convert_to_text", scope, position)
    if overloaded.is_a?(Error)
      return super(scope, position)
    end
    result = overloaded.call([], @scope, position)
    if result.is_a?(Error) then return result end
    if not result.is_a?(Text)
      return ConversionError.new("Conversion error, overridden method convert_to_text in type #{@name} returns #{result.class} and not Text", scope, position)
    end
    return result
  end

  ##
  # This method lets the user override the convert_to_number method in the superclass. This prevents error everytime
  # a Number object is required. If the user has overridden the method, it must also return a Text object.
  # Otherwise a ConversionError exception will be returned.
  def convert_to_number(scope, position)
    overloaded = @scope.get_operator("convert_to_number", scope, position)
    if overloaded.is_a?(Error)
      return super(scope, position)
    end
    result = overloaded.call([], @scope, position)
    if result.is_a?(Error) then return result end
    if not result.is_a?(Number)
      return ConversionError.new("Conversion error, overridden method convert_to_number in type #{@name} returns #{result.class} and not Number", scope, position)
    end
    return result
  end

  ##
  # This method lets the user override the copy method in the superclass. If the method
  # is not overridden the method will return itself and not a copy.
  def copy(scope, position)
    overloaded = @scope.get_operator("copy", scope, position)
    if overloaded.is_a?(Error)
      return self
    end
    return overloaded.call([other], @scope, position)
  end

  ##
  # Overrides the class method to returns the name of the Type instead of only Type.
  def class
    return @name
  end
end
