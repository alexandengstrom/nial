##
# Represent a position of a Token. This class is used to keep track
# where errors occur so information about where a error has occured can
# be printed to the terminal.
class Position
  attr_accessor :file, :line, :column

  ##
  # Creates a new position.
  def initialize(file, line, column)
    @file = file
    @line = line
    @column = column
  end
end
