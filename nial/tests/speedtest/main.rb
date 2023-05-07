require './lexer/lexer.rb'
require './exceptions/error.rb'
require './parser/parser.rb'
require './interpreter/interpreter.rb'
require './interpreter/scope'
require './lexer/position'


def run(filename, scope)
  data = File.read(filename)
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
  result = Interpreter.evaluate(result, scope)
  if result.is_a?(Error)
    puts result.display
    return
  end
end


start_time = Time.now
filename = "testfil.nial"
pos = Position.new(filename, 1, 1)
global_scope = Scope.new("global scope", nil, pos)
run(filename, global_scope)
end_time = Time.now

puts "Time elapsed: #{end_time - start_time}"
