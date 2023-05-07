require_relative "null"

##
# Represents a string in the Nial language
class Text < Null

  ##
  # Create a new Text object with the text sequence value
  def initialize(value)
    super(value)
  end

  ##
  # Gets called when the user wants to access a specific index of a string.
  # Tries to convert the parameter index to a number and returns a ConversionError exception if that fails.
  # Returns ListIndexOutOfRange exception if the index is out of range.
  # Otherwise the character on position index will be returned.
  def get_index(index, scope, position)
    index = index.convert_to_number(scope, position)
    if index.is_a?(Error) then return index end
    
    if index.value > @value.length or index.value < 1
      return ListIndexOutOfRange.new("Index out of range", scope, position)
    end
    return Text.new(@value[index.value-1])
  end

  ##
  # Gets called when the user wants to assign a new value to a specific index of a string.
  # The parameter index will be converted to a Number and the parameter new_value will
  # be converted to a Text. These operations can return the ConversionError exception if they fail.
  # If the index is out of range the exepction ListIndexOutOfRange will be returned.
  # Otherwise, the new value will be assigned to that index. Returns itself.
  def set_index(index, new_value, scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not change a constant Text sequence", scope, position)
    end
    
    new_value = new_value.convert_to_text(scope, position)
    if new_value.is_a?(Error) then return new_value end
    
    index = index.convert_to_number(scope, position)
    if index.is_a?(Error) then return index end
    
    if index.value > @value.length or index.value < 1
      return ListIndexOutOfRange.new("Index out of range", scope, position)
    end
    @value[index.value-1] = new_value.value
    return self
  end

  ##
  # This method is called when the operator + is used when a Text object is the first operand.
  def addition(other, scope, position)
    case other
    when Text
      return Text.new(@value + other.value)
    else
      return super(other, scope, position)
    end
  end

  ##
  # This method is called when the operator * is used when a Text object is the first operand.
  def multiplication(other, scope, position)
    case other
    when Number
      return Text.new(@value * other.value)
    else
      return super(other, scope, position)
    end
  end

  ##
  # This method is called when the operator == is used when a Text object is the first operand.
  def equals(other, scope, position)
    case other
    when Text
      return Boolean.new(@value == other.value)
    else
      return Boolean.new(false)
    end
  end

  ##
  # This method is called when the operator != is used when a Text object is the first operand.
  def not_equals(other, scope, position)
    case other
    when Text
      return Boolean.new(@value != other.value)
    else
      return Boolean.new(true)
    end
  end

  ##
  # This method is called when the operator > is used when a Text object is the first operand.
  def greater_than(other, scope, position)
    case other
    when Number
      return Boolean.new(@value.length > other.value)
    when Text
      return Boolean.new(@value.length > other.value.length)
    else
      return super(other, scope, position)
    end
  end

  ##
  # This method is called when the operator < is used when a Text object is the first operand.
  def less_than(other, scope, position)
    case other
    when Number
      return Boolean.new(@value.length < other.value)
    when Text
      return Boolean.new(@value.length < other.value.length)
    else
      return super(other, scope, position)
    end
  end

  ##
  # This method is called when the operator >= is used when a Text object is the first operand.
  def equals_or_greater_than(other, scope, position)
    case other
    when Number
      return Boolean.new(@value.length >= other.value)
    when Text
      return Boolean.new(@value.length >= other.value.length)
    else
      return super(other, scope, position)
    end
  end

  ##
  # This method is called when the operator <= is used when a Text object is the first operand.
  def equals_or_less_than(other, scope, position)
    case other
    when Number
      return Boolean.new(@value.length <= other.value)
    when Text
      return Boolean.new(@value.length <= other.value.length)
    else
      return super(other, scope, position)
    end
  end

  ##
  # This method is called when the operator += is used when a Text object is the first operand.
  def addition_assignment(other, scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not concatenate a constant Text sequence", scope, position)
    end
    
    case other
    when Text
      @value += other.value
      return self
    else
      return super(other, scope, position)
    end
  end

  ##
  # This method is called when the operator *= is used when a Text object is the first operand.
  def multiplication_assignment(other, scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not concatenate a constant Text sequence", scope, position)
    end
    
    case other
    when Number
      @value *= other.value
      return self
    else
      return super(other, scope, position)
    end
  end

  ##
  # Converts the Text object to a Boolean object with the value true if the Text is not empty.
  # Otherwise the value will be false.
  def convert_to_boolean(scope, position)
    if @value.length == 0 then return Boolean.new(false) end
    return Boolean.new(true)
  end

  ##
  # Gets called when the user want to output a Text object to the terminal.
  def display(_, _)
    return Text.new(@value)
  end

  ##
  # Returns the length of the Text as a Number object
  def length(scope, position)
    return Number.new(@value.length)
  end

  ##
  # Converts the Text object to a Number object.
  # Returns a ConversionError exception if the operation fails.
  def convert_to_number(scope, position)
    begin
      if @value.include?(".")
        value = @value.to_f
        return Number.new(value)
      else
        value = @value.to_i
        return Number.new(value)
      end
    rescue
      return ConversionError.new("Could not convert #{@value} to Number", scope, position)
    end
  end

  ##
  # Converts the Text object to a List object. Each character in the text sequence will be
  # one element in the returned List.
  def convert_to_list(scope, position)
    list = List.new
    @value.each_char {|char|
      list.add(Text.new(char))
    }
    return list
  end

  ##
  # Returns itself.
  def convert_to_text(scope, position)
    return self
  end

  ## Returns a copy of the Text object.
  def copy(scope, position)
    new_object = Text.new(@value.dup)
    new_object.constant = false
    return new_object
  end

  ##
  # Returns a copy of the Text object with all letters as uppercase.
  def upper(scope, position)
    return Text.new(@value.upcase)
  end

  ##
  # Returns a copy of the Text object with all letters as lowercase.
  def lower(scope, position)
    return Text.new(@value.downcase)
  end

  ##
  # Strips all whitespaces in the beginning and end of the Text object.
  def strip(scope, position)
    return Text.new(@value.strip)
  end

  ##
  # Left justifies the text with num amount of whitespaces.
  # Returns a ConversionError exception if num cannot be converted to a Number.
  def left_justify(num, scope, position)
    num = num.convert_to_number(scope, position)
    if num.is_a?(Error) then return num end
    
    return Text.new(@value.ljust(num.value))
  end

  ##
  # Right justifies the text with num amount of whitespaces.
  # Returns a ConversionError exception if num cannot be converted to a Number.
  def right_justify(num, scope, position)
    num = num.convert_to_number(scope, position)
    if num.is_a?(Error) then return num end
    
    return Text.new(@value.rjust(num.value))
  end

  ##
  # Substitutes all occurences of pattern with value.
  # Pattern can be a normal text sequence or a regular expression.
  # Both pattern and value will be converted to Text object and
  # will return a ConversionError exception if the operation fails.
  def sub(pattern, value, scope, position)
    pattern = pattern.convert_to_text(scope, position)
    if pattern.is_a?(Error) then return pattern end
    value = value.convert_to_text(scope, position)
    if value.is_a?(Error) then return value end
    
    regex = Regexp.new(/#{pattern.value}/)
    return Text.new(@value.gsub(regex, value.value))
  end

  ##
  # Split the Text sequence on newline-characters and return the elements
  # as a List object.
  def split_lines(scope, position)
    list = List.new
    lines = @value.split(/\n/)
    lines.each {|line|
      list.add(Text.new(line))
    }
    return list
  end

  ##
  # Split the Text sequence on all whitespace-characters and return the elements
  # as a List object.
  def split_words(scope, position)
    list = List.new
    lines = @value.split(/ /)
    lines.each {|line|
      new_line = line.split(/\n/)
      new_line.each {|n| list.add(Text.new(n)) }
    }
    return list
  end

  ##
  # Split the Text sequence on all occurences of the pattern provided and return the elements
  # as a list object. If pattern cannot be converted to a Text object the ConversionError exception
  # will be returned.
  def split(pattern, scope, position)
    pattern = pattern.convert_to_text(scope, position)
    if pattern.is_a?(Error) then return pattern end
    
    list = List.new
    lines = @value.split(pattern.value)
    lines.each { |line|
      list.add(Text.new(line))
    }
    return list
  end

  ##
  # Returns a subset of the Text sequence by slicing it. Parameters start and stop will be
  # converted to Number object. If they cannot be converted, the ConversionError exception will
  # be returned.
  def slice(start, stop, scope, position)
    start = start.convert_to_number(scope, position)
    if start.is_a?(Error) then return start end
    stop = stop.convert_to_number(scope, position)
    if stop.is_a?(Error) then return stop end

    return Text.new(@value[start.value-1..stop.value-1])
  end

  ##
  # Returns a subset of the Text sequence if the pattern matches
  # the beginning of the Text sequence. The parameter pattern will be converted to
  # a Text object and can return a ConversionError exception if the operation fails.
  def match(pattern, scope, position)
    pattern = pattern.convert_to_text(scope, position)
    if pattern.is_a?(Error) then return pattern end

    regex = Regexp.new(/^#{pattern.value}/)
    result = @value.match(regex)
    if !result
      return Null.new(nil)
    else
      return Text.new(result.to_s)
    end
  end
end
