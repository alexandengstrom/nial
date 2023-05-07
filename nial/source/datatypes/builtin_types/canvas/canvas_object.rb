##
# An object that exist inside a Canvas.
class CanvasObject
  attr_accessor :position_x, :position_y, :width, :height, :color

  ##
  # Create a new CanvasObject.
  def initialize(x, y, height, width, color)
    @position_x = x.value
    @position_y = y.value
    @width = width.value
    @height = height.value
    @color = color
  end

  ##
  # Move the CanvasObject in a specific direction.
  def move(dy, dx, scope, position)
    dx = dx.convert_to_number(scope, position)
    if dx.is_a?(Error) then return dx end
    dy = dy.convert_to_number(scope, position)
    if dy.is_a?(Error) then return dy end

    @position_x += dx.value
    @position_y += dy.value
  end

  ##
  # Takes another CanvasObject as parameter and calculates if the
  # two objects are intersecting. Returns a Boolean.
  def intersects_with(other, scope, position)
    if @position_x >= other.position_x + other.height ||
       @position_x + @height <= other.position_x ||
       @position_y > other.position_y + other.width ||
       @position_y + @width < other.position_y     
      return Boolean.new(false)
    else
      return Boolean.new(true)
    end
  end

  ##
  # Returns the position of the CanvasObject as a List object.
  def get_position(scope, position)
    list = List.new
    list.add(Number.new(@position_x))
    list.add(Number.new(@position_y))
    return list
  end

  ##
  # Moves the CanvasObject to a specific position.
  def set_position(x, y, scope, position)
    x = x.convert_to_number(scope, position)
    if x.is_a?(Error) then return x end
    y = y.convert_to_number(scope, position)
    if y.is_a?(Error) then return y end

    @position_x = x.value
    @position_y = y.value
  end

  ##
  # Returns itself.
  def copy(scope, position)
    return self
  end
end
