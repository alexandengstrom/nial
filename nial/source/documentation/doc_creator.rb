require_relative "../lexer/lexer"
require_relative "../parser/parser"
require_relative "../interpreter/interpreter"
require_relative "xml_writer"
require_relative "xml_parser"
require_relative "latex_creator"
require_relative "html_creator"

##
# This class is used to automatically create documentation from the
# source code.
class DocCreator
  @@root = nil

  ##
  # Initializes the XMLWriter.
  def DocCreator.init
    XMLWriter.init
  end

  ##
  # Saves the XML file and generates LaTeX and HTML documentation with
  # LatexCreator and HTMLCreator.
  def DocCreator.save
    new_path = "docs"
    new_dir = File.expand_path(new_path, File.dirname(@@root))

    if !Dir.exist?(new_dir)
      Dir.mkdir(new_dir)
    end

    subdir_paths = ["xml", "latex", "html"]
    subdir_paths.each { |subdir_path|
      subdir_full_path = File.join(new_dir, subdir_path)
      if !Dir.exist?(subdir_full_path)
        Dir.mkdir(subdir_full_path)
      end
    }
    
    XMLWriter.save
    
    data = XMLParser.parse
    LatexCreator.create(data)
    HTMLCreator.create(data)
  end

  ##
  # Create documentation from the filename provided
  def DocCreator.create(filename)
    if filename.is_a?(ImportNode)
      filename = import(filename)
    end
    
    if !@@root
      @@root = filename
    end
    
    $CREATE_DOCS = true

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
  end

  ##
  # Unpack all files included in the main file.
  def DocCreator.import(node)
    pos = Position.new("temp_pos", 1, 1)
    scope = Scope.new("temp_scope", nil, pos)
    filename = Interpreter.evaluate(node.filename, scope)
    if filename.is_a?(Error) then return filename end
    # Convert the filename to text, this is mainly because this method
    # will return an error if the object cannot be converted to text
    # This makes sure we have the correct datatype.
    filename = filename.convert_to_text(scope, node.position)
    if filename.is_a?(Error) then return filename end

    input_file_path = File.expand_path(node.position.file)
    file_path = File.join(File.dirname(input_file_path), filename.value)

    return file_path
  end
end
