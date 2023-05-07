##
# Represents a Token. Instances of this class is created in the Lexer
# and is then used in the Parser.
class Token
  attr_accessor :type, :value, :line, :column, :position

  ##
  # Creates a new Token.
  def initialize(type, value, line, column, position)
    @type = type
    @value = value
    @line = line
    @column = column
    @position = position
  end

  def to_string
    if @value
      return "#{@value}"
    else
      return "[#{@type}]"
    end
  end
end
