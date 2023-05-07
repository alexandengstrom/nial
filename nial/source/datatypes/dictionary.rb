require_relative "list"
require_relative "boolean"
require_relative "number"
require_relative "text"

##
# Represents a Hash table in the Nial language.
class Dictionary < Null

  ##
  # Create a new Dicionary. The parameter value should be an array of arrays with key/values.
  def initialize(value)
    super(value)
  end

  ##
  # Gets called when the user wants to output a Dictionary to the terminal.
  # This is done by calling display recursivly on all objects stored in the Dictionary.
  def display(scope, position)
    return Text.new("{" + @value.map{|v|
                      key = v[0].display(scope, position)
                      if key.is_a?(Error) then return key end
                      key = key.convert_to_text(scope, position)
                      if key.is_a?(Error) then return key end
                      
                      value = v[1].display(scope, position)
                      if value.is_a?(Error) then return value end
                      value = value.convert_to_text(scope, position)
                      if value.is_a?(Error) then return value end
                      "#{key.value} : #{value.value}"
                    }.join(", ") + "}")
  end

  ##
  # Created a new key-value pair or overrides the current value of a key.
  def set_index(index, new_value, scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not change a constant dictionary", scope, position)
    end

    if !(index.is_a?(Number) || index.is_a?(Text))
      return InvalidDatatype.new("Dictionary keys must be Text or Numbers", scope, position)
    end
    
    found_key = false
    @value.each {|pair|
      if pair[0].value == index.value
        pair[1] = new_value
        found_key = true
        break
      end
    }
    if not found_key then @value << [index, new_value] end    
    return new_value
  end

  ##
  # Returns the value of a specific key. Returns a KeyError exception if they key doesnt exist.
  def get_index(index, scope, position)
    if !(index.is_a?(Number) || index.is_a?(Text))
      return InvalidDatatype.new("Dictionary keys must be Text or Numbers", scope, position)
    end
    
    @value.each {|pair|
      if pair[0].value == index.value
        return pair[1]
      end
    }
    return DictionaryKeyError.new(index.value, scope, position)
  end

  ##
  # Returns a List object with all the keys in the Dictionary as elements.
  def get_keys(scope, position)
    keys = List.new
    @value.each {|pair|
      keys.add(pair[0])
    }
    return keys
  end

  ##
  # Returns a List object with all the values in the Dictionary as elements.
  def get_values(scope, position)
    values = List.new
    @value.each {|pair|
      values.add(pair[1])
    }
    return values
  end

  ##
  # Returns a List object with all key-value pairs as List objects.
  def get_pairs(scope, position)
    values = List.new
    @value.each {|pair|
      current_pair = List.new
      current_pair.add(pair[0])
      current_pair.add(pair[1])
      values.add(current_pair)
    }
    return values
  end

  ##
  # Returns a Boolean with value true if the key exists in the Dictionary. Otherwise false.
  def has_key(key, scope, position)
    @value.each {|pair|
      if pair[0].value == key.value
        return Boolean.new(true)
      end
    }
    return Boolean.new(false)
  end

  ##
  # Returns a Boolean with value true if the value exists in the Dictionary. Otherwise false.
  def has_value(value, scope, position)
    @value.each {|pair|
      if pair[1].value == value.value
        return Boolean.new(true)
      end
    }
    return Boolean.new(false)
  end

  ##
  # Return the number of key-value pairs in the Dictionary as a Number object.
  def length(scope, position)
    return Number.new(@value.length)
  end

  ##
  # Converts the Dictionary to a Boolean. The value will be false if the Dictionary is empty, otherwise true.
  def convert_to_boolean(scope, position)
    return Boolean.new(@value.length > 0)
  end

  ##
  # Converts the Dictionary to a Text object.
  def convert_to_text(scope, position)
    return self.display
  end

  ##
  # Converts the Dictionary to a List object by calling get_pairs.
  def convert_to_list(scope, position)
    return self.get_pairs(scope, position)
  end

  ##
  # Returns itself.
  def convert_to_dictionary(scope, position)
    return self
  end

  ##
  # Returns a copy of the Dictionary by calling copy on all the elements in the Dictionary.
  def copy(scope, position)
    new_dict = []
    @value.each {|pair|
      new_dict << [pair[0].copy(scope, position), pair[1].copy(scope, position)]
    }
   return Dictionary.new(new_dict)
  end

  ##
  # Removes all key-value pairs from the Dictionary.
  def clear(scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not clear a constant dictionary", scope, position)
    end
    
    @value = []
    return self
  end
end
