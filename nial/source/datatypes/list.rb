# coding: utf-8
require_relative "null"
require_relative "number"
require_relative "boolean"
require_relative "text"

class List < Null
  def initialize
    super(Array.new)
  end

  def fill_list(list)
    @value = list
  end

  def get_index(index, scope, position)
    index = index.convert_to_number(scope, position)
    if index.is_a?(Error) then return index end
    
    if index.value < 1 or index.value > @value.length
      return ListIndexOutOfRange.new("List index out of range", scope, position)
    end
    return @value[index.value-1]
  end

  def set_index(index, value, scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not change a constant list", scope, position)
    end
    
    index = index.convert_to_number(scope, position)
    if index.is_a?(Error) then return index end
    
    if index.value < 1 or index.value > @value.length
      return ListIndexOutOfRange.new("List index out of range", scope, position)
    end
    @value[index.value-1] = value
    return value
  end

  def addition(other, scope, position)
    new_list = self.copy(scope, position)
    if other.is_a?(List)
      other.value.each { |value|
        new_list.add(value)
      }
    else
      new_list.add(other)
    end
    return new_list
  end

  def display(scope, position)
    return Text.new("[" + @value.map{|v|
                      value = v.display(scope, position)
                      if value.is_a?(Error) then return value end
                      value = value.convert_to_text(scope, position)
                      if value.is_a?(Error) then return value end
                      "#{value.value}"
                    }.join(", ") + "]")
  end

  def length(scope, position)
    return Number.new(@value.length)
  end

  def add(value)
    @value << value
    return value
  end

  def convert_to_boolean(scope, position)
    return Boolean.new(!@value.empty?)
  end

  def convert_to_list(scope, position)
    return self
  end

  def append(value, scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not append values to a constant list", scope, position)
    end
    @value << value
    return value
  end

  def pop(scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not pop values from a constant list", scope, position)
    end
    
    if @value.length > 0
      last = @value.last
      @value.pop
      return last
    end
    return Null.new(nil)
  end

  def pop_first(scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not pop values from a constant list", scope, position)
    end
    
    if @value.length > 0
      first = @value.first
      @value = @value[1..@value.length]
      return first
    end
    return Null.new(nil)
  end

  def has_value(value, scope, position)
    @value.each {|v| if v.value == value.value then return Boolean.new(true) end }
    return Boolean.new(false)
  end

  def first(scope, position)
    if @value.length > 0 then return @value[0] end
    return Null.new(nil)
  end

  def last(scope, position)
    if @value.length > 0 then return @value[-1] end
    return Null.new(nil)
  end

  def join(separator, scope, position)
    if not separator.is_a?(Text)
      return InvalidDatatype.new("Separator must be a Text-object, not a #{@separator.class}", scope, position)
    end
    return Text.new(@value.map{|v|
                      value = v.display(scope, position)
                      if value.is_a?(Error) then return value end
                      value = value.convert_to_text(scope, position)
                      if value.is_a?(Error) then return value end
                      "#{value.value}"
                    }.join(separator.value))
  end

  def flip(scope, position)
    flipped = @value.reverse
    new_list = List.new
    flipped.each {|e| new_list.add(e) }
    return new_list
  end

  def empty(scope, position)
    return Boolean.new(@value.empty?)
  end

  def clear(scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not clear values from a constant list", scope, position)
    end
    
    @value = Array.new
    return Null.new(nil)
  end

  def insert(index, value, scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not insert values into a constant list", scope, position)
    end
    
    if index.value < -@value.length
      @value.insert(0, value)
    elsif index.value > @value.length+1
      @value.insert(@value.length, value)
    else
      @value.insert(index.value-1, value)
    end
    return self
  end

  def delete_index(index, scope, position)
    if @constant
      return ConstantAlreadyDefined.new("Can not delete values from a constant list", scope, position)
    end
        
    if not index.is_a?(Number)
      return "InvalidDatatype"
    elsif index.value > @value.length or index.value < 1
      return "Indexoutofrange"
    end
    @value.delete_at(index.value-1)
    return self
  end

  def slice(start, stop, scope, position)
    
    start = start.convert_to_number(scope, position)
    if start.is_a?(Error) then return start end
    if start.value < 1 || start.value > @value.length
      starting_value = 0
    else
      starting_value = start.value - 1
    end

    stop = stop.convert_to_number(scope, position)
    if stop.is_a?(Error) then return stop end
    if stop.value < start.value
      stop_value = starting_value
    elsif stop.value > @value.length
      stop_value = @value.length 
    else
      stop_value = stop.value
    end

    if stop_value - starting_value >= @value.length
      return self
    end

    list = List.new
    copy = self.copy(scope, position)
    (starting_value..stop_value).each { |index|
      list.add(copy.value[index])
    }
    return list
  end

  def copy(scope, position)
    new_list = List.new
    @value.each {|item|
      new_list.add(item.copy(scope, position))
    }
    new_list.constant = false
    return new_list
  end
end
