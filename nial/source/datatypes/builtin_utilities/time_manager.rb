require_relative "baseutility"
require_relative "../number"
require_relative "../builtin_types/time_stamp"
require "time"

##
# Represents a built in utility in the Nial language that lets the user
# get the current time.
class TimeManager < BaseUtility
  ##
  # Returns a TimeStamp object with the current time.
  def TimeManager.now(scope, position)
    return TimeStamp.new(Number.new(Time.now.to_f))
  end
end
  
