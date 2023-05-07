require_relative "../null"

##
# The interface of all built in types in the Nial language.
class BuiltInType < Null

  ##
  # Creates a new object
  def initialize()
    super(nil)
    @attributes = Hash.new
  end

  ##
  # Gets an attribute of the Type. Returns the attribute or the
  # VariableNotDefined exception.
  def get_attribute(attribute, scope, position)
    @attributes.each {|key, value|
      if key.value == attribute.value
        return value
      end
    }
    return "VARIABLE NOT DEFINED"
  end

  ##
  # Gets called when the user wants to ouput a BuiltInType to the terminal.
  def display(_, _)
    return Text.new("<#{self.class} at #{self.to_s.split(":")[1]}")
  end
end
