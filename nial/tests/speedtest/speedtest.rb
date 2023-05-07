class Base
  attr_accessor :first_attribute

  def initialize(first)
    @first_attribute = first
  end

  def get_first()
    return @first_attribute
  end
end

class Child < Base
  attr_accessor :second_attribute

  def initialize(first, second)
    super(first)
    @second_attribute = second
  end

  def set_first(num)
    @first_attribute = num
  end
end

def square(num)
  return num * num
end

x = 1
while x < 1000
  new_object = Child.new(5, 10)
  new_object.set_first(7)
  new_value = new_object.get_first()
  new_list = Array.new
  for y in (1..20)
    if new_value == y
      dict = {"key1"=> 1, "key2"=> 2, "key3"=> 3, "key4" => 4, "key5" => 5, "key6" => 6, "key7" => 7, "key8" => 8}
      dict[1] = new_object.second_attribute
      new_list << dict["key3"]
    else
      temp = new_object.first_attribute
    end
  end

  for item in new_list
    temp = square(item)
  end

  begin
    error = 1/0
  rescue
    error = 1
  end

  x = x + 1
end
