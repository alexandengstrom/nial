##
# The class represents a return action inside a function or a method.
# If the keyword return is used in the language, an instance of this class
# will be returned.
#
# ==== Attributes
# +value+ is the value that should be returned, will be nil if no return value.

class ReturnAction
  attr_accessor :value
  
  def initialize(value)
    @value = value
  end
end

##
# This class represents a break action inside loops.
class BreakAction end

##
# This class represents a next action inside loops.
class NextAction end
