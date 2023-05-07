#!/usr/local/bin/ruby -w

require_relative 'lexer/lexer.rb'
require_relative 'exceptions/error.rb'
require_relative 'parser/parser.rb'
require_relative 'interpreter/interpreter.rb'
require_relative 'scope/scope'
require_relative 'position/position'
require_relative "documentation/xml_writer"
require_relative "documentation/doc_creator"


def run(data, scope, filename = "interpreted")
  lexer = Lexer.new
  if (result = lexer.tokenize(data, filename)).is_a?(Error)
    puts result.display
    return
  end
  parser = Parser.new(result)
  if (result = parser.parse).is_a?(Error)
    puts result.display
    return
  end
  begin
    result = Interpreter.evaluate(result, scope)
    if result.is_a?(Error)
      puts result.display
      return
    end
  rescue Interrupt
    exit 0
  end
end

if ARGV.length < 1
  pos = Position.new("interpreted mode", 1, 1)
  global_scope = Scope.new("global scope", nil, pos)
  print "=> "
  command  = gets.gsub("\n", "")
  while command != "exit"
    run(command, global_scope)
    print "=> "
    command  = gets.gsub("\n", "")
  end
else
  if ARGV[0] == "document"
    if ARGV.length > 1
      filename = ARGV[1]
      DocCreator.init
      DocCreator.create(filename)
      DocCreator.save
    else
      "ERROR"
    end
  else
    $CREATE_DOCS = false
    filename = ARGV[0]
    data = File.read(filename)
    pos = Position.new(filename, 1, 1)
    global_scope = Scope.new("global scope", nil, pos)
    run(data, global_scope, filename)
  end
end
