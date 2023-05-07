require_relative "../builtintype"
require_relative "../../../exceptions/error"
require_relative "canvas_object"

##
# A graphics renderer in the Nial language. Can be used to output graphics to
# the terminal.
class Canvas < BuiltInType

  ##
  # Create a new Canvas object.
  def initialize()
    super()
    
    @objects = Array.new
    
    @width = 0
    @height = 0
    @pixels = Array.new(@height) { Array.new(@width, "  ") }
    @colors = Array.new(@height) { Array.new(@width, "\e[0m") }

    @color_map = {
      "black" => "\e[40m",
      "red" => "\e[41m",
      "green" => "\e[42m",
      "yellow" => "\e[43m",
      "blue" => "\e[44m",
      "magenta" => "\e[45m",
      "cyan" => "\e[46m",
      "white" => "\e[47m",
      "default" => "\e[49m",
      "pink" => "\e[48;5;218m",
      "orange" => "\e[48;5;208m",
      "light_blue" => "\e[48;5;109m",
      "coral" => "\e[48;5;209m",
      "purple" => "\e[48;5;165m",
      "teal" => "\e[48;5;30m",
      "gold" => "\e[48;5;220m",
      "lavender" => "\e[48;5;183m",
      "salmon" => "\e[48;5;173m",
      "sky_blue" => "\e[48;5;117m",
      "rose" => "\e[48;5;211m",
      "lime_green" => "\e[48;5;118m",
      "dark_red" => "\e[48;5;88m",
      "turquoise" => "\e[48;5;80m",
      "olive" => "\e[48;5;58m",
      "navy" => "\e[48;5;17m",
      "mauve" => "\e[48;5;183m",
      "peach" => "\e[48;5;218m",
      "maroon" => "\e[48;5;124m",
      "eggplant" => "\e[48;5;54m",
      "mustard" => "\e[48;5;178m"
    }
  end

  ##
  # Set the dimensions of the Canvas. The parameter width and heigh
  # will be converted to Numbers. Returns ConversionError exception
  # if conversion fails.
  def set_dimensions(width, height, scope, position)
    width = width.convert_to_number(scope, position)
    if width.is_a?(Error) then return width end
    height = height.convert_to_number(scope, position)
    if height.is_a?(Error) then return height end

    @width = width.value
    @height = height.value
    @pixels = Array.new(@height) { Array.new(@width, "  ") }
    @colors = Array.new(@height) { Array.new(@width, "\e[0m") }
  end

  ##
  # Set a specific pixel on the Canvas to a specific color
  def set_pixel(x, y, color, scope, position)
    @colors[y.value][x.value] = get_color(color.value)
  end

  ##
  # Update the positions of all CanvasObject objects existing
  # on the Canvas.
  def update(scope, position)
    @objects.each { |object|
      (object.position_y..object.position_y+object.width).each { |y|
        (object.position_x..object.position_x+object.height).each {|x|
          if x < @width && x >= 0 && y < @height && y >= 0
            @colors[y][x] = object.color
          end
        }
      }
    }
  end

  ##
  # Render the new frame to the terminal.
  def render(scope, position)    
    new_frame = @pixels.map.with_index { |row, y|
      row.map.with_index { |pixel, x|
        "#{@colors[y][x]}#{pixel}\e[0m"
      }.join("")
    }.join("\n")
    system("clear")
    puts new_frame
  end

  ##
  # Fill the entire Canvas with a specific color
  def fill(color, scope, position)
    (0..@width-1).each { |x|
      (0..@height-1).each { |y|
        @colors[y][x] = get_color(color)
      }
    }
  end
  
  ##
  # Get a color from the color map
  def get_color(color)
    if not color.is_a?(Text)
      return @color_map["white"]
    end
    
    if @color_map.has_key?(color.value)
      return @color_map[color.value]
    else
      return @color_map["white"]
    end
  end

  ##
  # Adds a new CanvasObject to the Canvas and returns the created object.
  def add(x, y, height, width, color, position, scope)
    x = x.convert_to_number(scope, position)
    if x.is_a?(Error) then return x end
    y = y.convert_to_number(scope, position)
    if y.is_a?(Error) then return y end
    width = width.convert_to_number(scope, position)
    if width.is_a?(Error) then return width end
    height = height.convert_to_number(scope, position)
    if height.is_a?(Error) then return height end

    object = CanvasObject.new(x, y, height, width, get_color(color))
    @objects << object
    return object
  end

  ##
  # Investigates if a CanvasObject is inside the Canvas or not. Returns a Boolean.
  def inside(object, scope, position)
    x_axis = object.position_x >= 0 && object.position_x + object.width <= @width
    y_axis = object.position_y >= 0 && object.position_y + object.height <= @height

    if x_axis && y_axis
      return Boolean.new(true)
    else
      return Boolean.new(false)
    end
  end
end
