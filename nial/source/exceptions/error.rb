##
# The base class of all errors in the Nial language.
# Stores the type of error, a description and the position of the error.
class Error
  attr_accessor :line, :column, :position
  def initialize(type, description, position)
    @type = type
    @description = description + "\n"
    @position = position
  end

  ##
  # Can be used to add a helper message to the exception.
  # to help the user find the error.
  def add_suggestion(helper)
    @description += "\n" + "\e[36mHelper: #{helper}\e[0m"
  end

  ##
  # The method is used to find the line of the error and include
  # that line in the error message.
  def generate_line
    begin
      input_file_path = File.expand_path(@position.file)
      lines = File.read(input_file_path).split("\n")
    rescue
      lines = ""
    end
    
    line = "\e[31m#{lines[@position.line-1]}\e[0m" + "\n"
    line = line.gsub("\t", " ")
    spaces = (position.column-1)
    if spaces < 0 then spaces = 0 end
    pointer = " " * spaces + "^\n"
    return line + pointer
  end

  ##
  # The method gets called from the main program to display the error
  # for the user.
  def display
    frame = "==" * 40
    title = " "*30 + "#{@type}"
    pos = "\n\nIn file #{@position.file}, line #{@position.line}, column #{@position.column}:"
    description = "\n#{@type}: #{@description}\n\n"
    line = "The error occured in line:\n" + generate_line
    return frame + "\n" + title + pos + description + line + frame
  end
end

##
# Is being created in the Lexer if the lexer cannot tokenize the input correctly.
class InvalidCharacterError < Error
  def initialize(character, position)
    super("Invalid Character Error", "Invalid character -> #{character} <-", position)
  end
end

##
# The base class of parsing Errors.
class ParsingError < Error
  def initialize(token, description, position)
    super("Parsing Error", description, position)
  end
end

##
# Is being created in the Parser if an unexpected Token occurs.
# Stores the unexpected token and which tokens was expected.
class UnexpectedTokenError < ParsingError
  def initialize(token, expected, position, suggestion = "")
    super(token, "Unexpected Token Error -> #{token.value} <-\nExpected: [#{expected}]", position)
  end
end

class ExpectedEndOfInputError < ParsingError
  def initialize(token, position)
    super(token, "Unexpected Token Error -> #{token.value} <-\nExpected end of input", position)
  end
end

##
# Base class of runtime errors.
class Runtime_Error < Error
  def initialize(description, scope, position)
    super("Runtime Error", description, position)
    @scope = scope
  end

  ##
  # Gets called from the main program when an runtime error has occured
  # to display the error for the user.
  def display
    frame = "==" * 40
    title = " "*30 + "#{@type}"
    position = "\n\nIn file #{@position.file}, line #{@position.line}, column #{@position.column}:"
    description = "\n#{@type}: #{@description}\n"
    line = "\nThe error occured in line:\n" + generate_line
    traceback = "\n\nTraceback (most recent call first):\n#{generate_traceback(@scope)}"
    return frame + "\n" + title + position + description + line + traceback + frame
  end

  ##
  # Generates a traceback by calling the method to_string in Scope class.
  def generate_traceback(scope)
    return "\e[33m#{scope.to_string}\e[0m"
  end
end

##
# Created when an operator is being used on an object that doesnt
# support that operator.
class InvalidOperator < Runtime_Error
  def initialize(description, scope, position)
    super(description, scope, position)
  end
end

##
# Created when division by zero occurs.
class DivisionByZero < Runtime_Error
  def intialize(description, scope, position)
    super(description, scope, position)
  end
end

##
# Created when the user tries to access a variable that is not defined
# in the current scope.
class VariableNotDefined < Runtime_Error
  def initialize(identifier, scope, position)
    super("Variable \"#{identifier.value}\" is not defined", scope, position)
  end
end

##
# Created when the user tries to access a constant that is not defined
# in the current scope.
class ConstantNotDefined < Runtime_Error
  def initialize(utility, identifier, scope, position)
    super("Utility \"#{utility}\" has no attribute named \"#{identifier.value}\".", scope, position)
  end
end

##
# Created when the user tries to redefine a constant object.
class ConstantAlreadyDefined < Runtime_Error
  def initialize(description, scope, position)
    super(description, scope, position)
  end
end

##
# Created when incorrect number of arguments is passed to a function or method.
class WrongNumberOfArguments < Runtime_Error
  def initialize(arguments_length, parameters_length, scope, position)
    super("Wrong Number of arguments, expected #{parameters_length}, got #{arguments_length}.", scope, position)
  end
end

##
# Created when an object is being converted to a type it cannot be converted into.
class ConversionError < Runtime_Error
  def initialize(description, scope, position)
    super(description, scope, position)
  end
end

##
# Created when the return keyword is used outside a function or method.
class ReturnError < Runtime_Error
  def initialize(scope, position)
    super("Cannot return outside a function", scope, position)
  end
end

##
# Created when the break keyword is used outside a loop.
class BreakError < Runtime_Error
  def initialize(scope, position)
    super("Can only use break-keyword in loops", scope, position)
  end
end

##
# Created when the next keyword is used outside a loop
class NextError < Runtime_Error
  def initialize(scope, position)
    super("Can only use next-keyword in loops", scope, position)
  end
end

##
# Created when an invalid datatype is passed to a function or method
# that requires a specific datatype.
class InvalidDatatype < Runtime_Error
  def initialize(description, scope, position)
    super(description, scope, position)
  end                             
end

##
# Created when the stack gets too big.
class ToMuchRecursionError < Runtime_Error
  def initialize(description, scope, position)
    super(description, scope, position)
  end
end

##
# Created when the user tries to access an index that doesnt exist.
class ListIndexOutOfRange < Runtime_Error
  def initialize(description, scope, position)
    super(description, scope, position)
  end
end

##
# Created when the user triesnto access a key that doesnt exist.
class DictionaryKeyError < Runtime_Error
  def initialize(key, scope, position)
    super("Key Error. Dictionary has no key named \"#{key}\".", scope, position)
  end
end

##
# Created when a method is called that doesnt exist.
class MethodMissing < Runtime_Error
  def initialize(description, scope, position)
    super(description, scope, position)
  end
end

##
# Created when a file operation fails.
class FileError < Runtime_Error
  def initialize(description, scope, position)
    super(description, scope, position)
  end
end

##
# Created when the user is trying to use a Type that is not defined.
class TypeNotDefined < Runtime_Error
  def initialize(type, scope, position)
    super("Type #{type} is not defined", scope, position)
  end
end
