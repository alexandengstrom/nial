require_relative '../../source/lexer/lexer.rb'
require_relative '../../source/exceptions/error.rb'
require_relative '../../source/parser/parser.rb'
require_relative '../../source/interpreter/interpreter.rb'
require_relative '../../source/scope/scope'
require_relative '../../source/position/position'


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
filename = "speedtest.nial"
pos = Position.new(filename, 1, 1)
global_scope = Scope.new("global scope", nil, pos)
run(filename, global_scope)
end_time = Time.now
nial = end_time - start_time

start_time = Time.now
eval(File.read("speedtest.rb"))
end_time = Time.now
ruby = end_time - start_time

result = nial/ruby

string = "#{Time.now.strftime("%d/%m/%Y %H:%M")}".ljust(15) + "\n\n"
string += "This file do random operations of different types:\n"
string += "Nial code executed in " + "#{nial.round(3)}" + " seconds" + "\n"
string += "Ruby code executed in " + "#{ruby.round(3)}" + " seconds" + "\n\n"
string += "Nial is #{result.round(3)} times slower than Ruby" + "\n\n" + "#{'='*50}\n" 

puts string
final_data = string
puts string = ""


start_time = Time.now
filename = "find_primes.nial"
pos = Position.new(filename, 1, 1)
global_scope = Scope.new("global scope", nil, pos)
run(filename, global_scope)
end_time = Time.now
nial = end_time - start_time

start_time = Time.now
eval(File.read("find_primes.rb"))
end_time = Time.now
ruby = end_time - start_time

result = nial/ruby

string += "Find all primes up to 1000 and append them to a list:\n"
string += "Nial code executed in " + "#{nial.round(3)}" + " seconds" + "\n"
string += "Ruby code executed in " + "#{ruby.round(3)}" + " seconds" + "\n\n"
string += "Nial is #{result.round(3)} times slower than Ruby" + "\n\n" + "#{'='*50}\n" 

puts string
final_data += string



append_to_file = false
if append_to_file
  open("./speedtest/logfile.txt", "a") {|f|
    f << string
  }
end
