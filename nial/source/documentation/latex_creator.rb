require 'rexml/document'

##
# Responsible for creating a LaTeX document from the data the XMLParser returns.
class LatexCreator

  ##
  # Iterates through all objects in the data and creates LaTeX document from that data.
  def LatexCreator.create(data)

    output = "\\documentclass{article}\n"
    output += "\\usepackage{amsmath}\n"
    output += "\\title{Documentation}"
    output += "\\begin{document}"
    output += "\\maketitle"
    output += "\\newpage"
    output += "\\tableofcontents"
    output += "\\newpage"


    
    output += "\\section{Types}"
    data["types"].each { |type|
      output += "\\subsection{#{type["name"]}}\n"
      if type.has_key?("extends")
        output += "{\\bf Inherits from: #{type["extends"]}}\\\\"
      end
      output += type["description"]

      if type["attributes"].length > 0
        output += "\\subsubsection*{Attributes}\n"
        output += "The type {\\it #{type['name']}} has the following attributes:\n\n"
        output += "\\begin{itemize}\n"
        type["attributes"].each { |attribute|
          output += "\\item {\\bf #{attribute['name']}}: #{attribute['description']}\n" 

        }
        output += "\\end{itemize}\n"
      end

      if type["methods"].length > 0
        output += "\\subsubsection*{Methods}\n"
        output += "The type {\\it #{type['name']}} has the following methods:\n\n"
        output += "\\begin{itemize}"
        type["methods"].each { |method|
          param_names = method["parameters"].map { |param| param["name"] }
          param_names = param_names.map { |name|
            method["parameters"].find { |param|
              param["name"] == name }["copy"] == "true" ? "#{name} (copy)" : name }
          param_names = param_names.join(", ")
          output += "\\item {\\bf #{method['name']}(#{param_names})}: #{method['description']}\n" 
        }
        output += "\\end{itemize}"
      end
    }

    output += "\\section{Utilities}"
    data["utilities"].each { |type|
      output += "\\subsection{#{type["name"]}}\n"
      if type.has_key?("extends")
        output += "{\\bf Inherits from: #{type["extends"]}}\\\\"
      end
      output += type["description"]

      if type["attributes"].length > 0
        output += "\\subsubsection*{Attributes}\n"
        output += "The type {\\it #{type['name']}} has the following attributes:\n\n"
        output += "\\begin{itemize}\n"
        type["attributes"].each { |attribute|
          output += "\\item {\\bf #{attribute['name']}}: #{attribute['description']}\n" 

        }
        output += "\\end{itemize}\n"
      end

      if type["methods"].length > 0
        output += "\\subsubsection*{Methods}\n"
        output += "The type {\\it #{type['name']}} has the following methods:\n\n"
        output += "\\begin{itemize}"
        type["methods"].each { |method|
          param_names = method["parameters"].map { |param| param["name"] }
          param_names = param_names.map { |name|
            method["parameters"].find { |param|
              param["name"] == name }["copy"] == "true" ? "#{name} (copy)" : name }
          param_names = param_names.join(", ")
          output += "\\item {\\bf #{method['name']}(#{param_names})}: #{method['description']}\n" 
        }
        output += "\\end{itemize}"
      end
    }

    output += "\\end{document}"
    input_file_path = File.expand_path(ARGV[1])
    path = File.join(File.dirname(input_file_path), "docs/latex/docs.tex")

    output = output.gsub(/\_/, "\\_")
    
    File.write(path, output)
  end
end
