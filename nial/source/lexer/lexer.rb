# coding: utf-8
require_relative '../token/token'
require_relative '../exceptions/error.rb'
require_relative '../position/position'

##
# The lexer is responsible for the lexicographical analysis
#
# ==== Public methods
# #tokenize
#

class Lexer

  ##
  # Creates a new instance of the Lexer class.
  # The constructor does not take any parameters.
  #
  # * Initializes the array for +available_tokens+.
  # * Calls the method #define_tokens.
  
  def initialize
    @available_tokens = Array.new
    self.define_tokens
  end

  ##
  # Tokenizes the entire string passed as parameter. Uses the attribute +available_tokens+
  # to detect tokens. When a token is found
  # an instance of the class [Token] will be initialized and added to an array.
  # When the tokenization is finished, the array of tokens will be returned.
  
  def tokenize(string, filename = "main")
    tokens_found = []
    current_line = 1
    current_column = 1
    @token_found = false
    while not string.empty?
      @available_tokens.each { | current_token |
        match = string.match(current_token["pattern"])
        if match
          @token_found = true
          match = match.to_s
          if not [:SPACE, :TAB, :COMMENT].include?(current_token["symbol"])
            position = Position.new(filename, current_line, current_column)
            tokens_found << Token.new(current_token["symbol"], current_token["block"].call(match), current_line, current_column, position)
          end   
          string = self.move_cursor(string, match.length)
          current_column += match.length
          if match == "\n"
            current_line += 1
            current_column = 1
          elsif current_token["symbol"] == :DOC_COMMENT
            match.each_char {|char|
              if char == "\n"
                current_line += 1
                current_column = 1
              else
                current_column += 1
              end
            }
          end
          break
        end   
      }
      if not @token_found then return InvalidCharacterError.new(string[0], Position.new(filename, current_line, current_column)) else @token_found = false end
    end
    return tokens_found
  end

  private
  
  ##
  # Adds a match pattern and the corresponding token type and block to +available_tokens+.
  
  def add_token(symbol, pattern, &block)
    @available_tokens << {"symbol" => symbol, "pattern" => Regexp.new("\\A" + pattern.source), "block" => block}
  end

  ##
  # The method is used to delete tokenized characters from the string that are
  # currently being tokenized. The method is used in the method #tokenize.

  def move_cursor(string, characters)
    return string[characters..-1]
  end

  ##
  # Defining all token types, their match patterns and their codeblock.

  def define_tokens
    self.add_token(:COMMENT, /\#.*$/) { nil }
    self.add_token(:DOC_COMMENT, /\$[\s\S]*?\$/) { |t| t.gsub("$", "") }
    self.add_token(:NEWLINE, /\n/) { nil }
    self.add_token(:TAB, /\t/) { nil }
    self.add_token(:TAB, /    /) { nil }
    self.add_token(:SPACE, / /)
    self.add_token(:FLOAT, /\d+\.\d+/) { |t| t.to_f }
    self.add_token(:INT, /\d+/) { |t| t.to_i }
    self.add_token(:DOT, /\./) { "." }
    self.add_token(:AT, /\@/) { "@" }
    self.add_token(:USE, /use/) { "use" }
    self.add_token(:PIPE, /\|/) { "|" }
    self.add_token(:ADDITION_ASSIGNMENT, /\+=/) { "+=" }
    self.add_token(:SUBTRACTION_ASSIGNMENT, /\-=/) { "-=" }
    self.add_token(:DIVISION_ASSIGNMENT, /\/=/) { "/=" }
    self.add_token(:MULTIPLICATION_ASSIGNMENT, /\*=/) { "*=" }
    self.add_token(:ADDITION, /\+/) { "+" }
    self.add_token(:SUBTRACTION, /\-/) { "-" }
    self.add_token(:MULTIPLICATION, /\*/) { "*" }
    self.add_token(:DIVISION, /\//) { "/" }
    self.add_token(:MODULO, /\%/) { "%" }
    self.add_token(:EXPONENT, /\^/) { "^" }
    self.add_token(:EQUALS, /\==/) { "==" }
    self.add_token(:NOT_EQUALS, /\!=/) { "!=" }
    self.add_token(:EQUALS_OR_GREATER_THAN, /\>=/) { ">=" }
    self.add_token(:EQUALS_OR_LESS_THAN, /\<=/) { "<=" }
    self.add_token(:GREATER_THAN, /\>/) { ">" }
    self.add_token(:LESS_THAN, /\</) { "<" }
    self.add_token(:NOT, /not/) { "not" }
    self.add_token(:AND, /and/) { "and" }
    self.add_token(:OR, /or/) { "or" }
    self.add_token(:COPY, /copy /) {|t| t.to_s}
    self.add_token(:EXTEND, /extend/) {|t| t.to_s}
    self.add_token(:TRY, /try/) {|t| t.to_s}
    self.add_token(:CATCH, /catch/) {|t| t.to_s}
    self.add_token(:ASSIGNMENT, /=/) {|t| t.to_s}
    self.add_token(:LEFT_PAREN, /\(/) {|t| t.to_s}
    self.add_token(:RIGHT_PAREN, /\)/) {|t| t.to_s}
    self.add_token(:LEFT_SQUARE, /\[/) {|t| t.to_s}
    self.add_token(:RIGHT_SQUARE, /\]/) {|t| t.to_s}
    self.add_token(:LEFT_CURL, /\{/) {|t| t.to_s}
    self.add_token(:RIGHT_CURL, /\}/) {|t| t.to_s}
    self.add_token(:COLON, /\:/) {|t| t.to_s}
    self.add_token(:WITH, /with/) {|t| t.to_s}
    self.add_token(:ASSIGN, /assign/) {|t| t.to_s}
    self.add_token(:COUNT, /count/) {|t| t.to_s}
    self.add_token(:FROM, /from/) {|t| t.to_s}
    self.add_token(:TO, /to(?=[ ])/) {|t| t.to_s}
    self.add_token(:LOAD, /load(?=[ ])/) {|t| t.to_s}
    self.add_token(:INTO, /into(?=[ ])/) {|t| t.to_s}
    self.add_token(:IN, /in(?=[ ])/) {|t| t.to_s}
    self.add_token(:FOR_EVERY, /for every(?=[ ])/) {|t| t.to_s}
    self.add_token(:WHILE, /while(?=[ ])/) {|t| t.to_s}
    self.add_token(:BREAK, /break/) {|t| t.to_s}
    self.add_token(:NEXT, /next/) {|t| t.to_s}
    self.add_token(:DISPLAY, /display /) {|t| t.to_s}
    self.add_token(:CREATE, /create /) {|t| t.to_s}
    self.add_token(:LET_USER_ASSIGN, /let user assign/) {|t| t.to_s}
    self.add_token(:THEN, /then/) {|t| t.to_s}
    self.add_token(:IF, /if/) {|t| t.to_s}
    self.add_token(:ELSE_IF, /else if/) {|t| t.to_s}
    self.add_token(:ELSE, /else/) {|t| t.to_s}
    self.add_token(:STOP, /stop/) {|t| t.to_s}
    self.add_token(:CALL, /call/)  {|t| t.to_s}
    self.add_token(:RETURN, /return/)  {|t| t.to_s}
    self.add_token(:DEFINE_FUNCTION, /define function/) {|t| t.to_s}
    self.add_token(:DEFINE_METHOD, /define method/) {|t| t.to_s}
    self.add_token(:DEFINE_TYPE, /define type/) {|t| t.to_s}
    self.add_token(:DEFINE_UTILITY, /define utility/) {|t| t.to_s}
    self.add_token(:COMMA, /\,/) {|t| t.to_s}
    self.add_token(:BOOLEAN, /True/) {|t| true}
    self.add_token(:BOOLEAN, /False/) {|t| false}
    self.add_token(:NULL, /Null/) {|t| nil}
    self.add_token(:CONSTANT_IDENTIFIER, /[A-Z]{2}[A-Z_0-9]*\b/) {|t| t.to_s}
    self.add_token(:TYPE_IDENTIFIER, /[A-Z]\w*/) {|t| t.to_s}
    self.add_token(:IDENTIFIER, /\w+/) {|t| t.to_s}
    self.add_token(:TEXT, /"(?:\\.|[^\\"])*"/) {|t| t.to_s}
  end
end
