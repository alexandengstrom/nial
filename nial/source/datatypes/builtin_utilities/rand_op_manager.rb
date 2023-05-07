require_relative "baseutility"

##
# Represents a built in utility for random operations in the Nial language.
class RandOpManager < BaseUtility
  @@random = Random.new

  ##
  # Returns an integer between start and stop. These parameters will be converted
  # to Number. If conversion fails the exception ConversionError will be returned.
  # Otherwise a random integer will be returned as a Number object.
  def RandOpManager.get_integer(start, stop, scope, position)
    start = start.convert_to_number(scope, position)
    if start.is_a?(Error) then return start end

    stop = stop.convert_to_number(scope, position)
    if stop.is_a?(Error) then return stop end
    
    return Number.new(@@random.rand(start.value..stop.value))
  end

  ##
  # Returns a float between start and stop. These parameters will be converted to Number.
  # If conversion fails the exception ConversionError will be returned.
  # Otherwise a random float will be returned as a Number object.
  def RandOpManager.get_float(start, stop, scope, position)
    start = start.convert_to_number(scope, position)
    if start.is_a?(Error) then return start end

    stop = stop.convert_to_number(scope, position)
    if stop.is_a?(Error) then return stop end
    
    return Number.new(@@random.rand(start.value.to_f..stop.value.to_f))
  end

  ##
  # Returns a random pick from the List object provided as parameter.
  # If the parameter List cannot be converted to a List, the
  # ConversionError exception will be returned.
  # If the List is empty Null object will be returned.
  def RandOpManager.pick_item(list, scope, position)
    list = list.convert_to_list(scope, position)
    if list.is_a?(Error) then return list end

    if list.value.length < 1 then return Null.new(nil) end
    index = @@random.rand(0..list.value.length-1)
    return list.value[index]
  end
end
