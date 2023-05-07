require 'erb'

##
# Responsible for creating HTML documentation from the data parsed by
# the XMLParser.
class HTMLCreator

  ##
  # The main method of the process. Calls all other methods.
  def HTMLCreator.create(data)
    input_file_path = File.expand_path(ARGV[1])
    output_dir = File.join(File.dirname(input_file_path), "docs/html")
    

    data["types"].each { |type|
      create_page(type, output_dir)
    }

    data["utilities"].each { |utility|
      create_page(utility, output_dir)
    }

    create_menu(data, output_dir)
    create_index(output_dir)
    create_css(output_dir)
    create_main(output_dir)
    
  end

  ##
  # Creates a HTML page for a Type or Utility.
  def HTMLCreator.create_page(type, output_dir)
    output = start_html(type["name"])
    output += "<div class\"maincontent\">"
    output += "<h2>#{type['name']}</h2>"
    if type.has_key?("extends")
      output += "<h5> Extends type <a href=\"#{type['extends'].downcase}.html\">#{type['extends']}</a></h5><br>"
    end
    output += "<h3>Description:</h3>"
    output += "<p>#{type["description"]}</p>"
    if type["attributes"].length > 0
      output += "<h3>Attributes:</h3>"
      output += "<ul>"
      type["attributes"].each { |attribute|
        output += "<li><p><b>#{attribute['name']}</b>: #{attribute['description']}</p></li>"
      }

      output += "</ul>"
    end

    if type["methods"].length > 0
      output += "<h3>Methods:</h3>"
      output += "<ul>"
      type["methods"].each { |method|
        param_names = method["parameters"].map { |param| param["name"] }
        param_names = param_names.map { |name|
          method["parameters"].find { |param|
            param["name"] == name }["copy"] == "true" ? "#{name} (copy)" : name }
        param_names = param_names.join(", ")
        
        output += "<li><p><b>#{method['name']}(#{param_names})</b>: #{method['description']}</p></li>"
      }
      output += "</ul>"
    end
    output += "</div>"
    output += end_html
    
    File.write("#{output_dir}/#{type['name'].downcase}.html", output)
  end

  ##
  # Creates the menu bar HTML page.
  def HTMLCreator.create_menu(data, output_dir)
    output = start_html("Menu")
    output += "<div class=\"menubar\">"
    output += "<h5>Types:</h5>"
    output += "<ul>"
    data["types"].each { |type|
      output += "<li><a href=\"#{type['name'].downcase}.html\" target=\"mainframe\">#{type['name']}</a></li>"
    }
    output += "</ul>"

    output += "<h5>Utilities:</h5>"
    output += "<ul>"
    data["utilities"].each { |type|
      output += "<li><a href=\"#{type['name'].downcase}.html\" target=\"mainframe\">#{type['name']}</a></li>"
    }
    output += "</ul>"
    output += "</div>"
    output += end_html

    File.write("#{output_dir}/menu.html", output)
  end

  ##
  # Creates the index.html page.
  def HTMLCreator.create_index(output_dir)
    output = start_html("Documentation")
    output += <<-HTML
    <div class="headerbar">
    <h1>Nial Documentation</h1>
    <h5>Generated #{Time.now.strftime("%d/%m/%Y %H:%M")}</h5>
    </div>
    <table>
      <tr>
        <td>
          <iframe src="menu.html" width="300" height="1000"></iframe>
        </td>
        <td>
          <iframe name="mainframe" src="main.html" width="700" height="1000"></iframe>
        </td>
      </tr>
    </table>
HTML
    output += end_html

    File.write("#{output_dir}/index.html", output)
  end

  ##
  # Copies the CSS template to the correct directory.
  def HTMLCreator.create_css(output_dir)
    css = File.expand_path("../templates/style.css", __FILE__)
    css = File.read(css)
    File.write("#{output_dir}/style.css", css)
  end

  ##
  # Creates the main page.
  def HTMLCreator.create_main(output_dir)
    main = File.expand_path("../templates/main.html", __FILE__)
    main = File.read(main)
    File.write("#{output_dir}/main.html", main)
  end

  ##
  # Creates all necessary starting HTML code.
  def HTMLCreator.start_html(title)
    output = <<-HTML
      <!DOCTYPE html>
      <html>
        <head>
        <meta charset="utf-8">
        <title>#{title}</title>
        <link rel="stylesheet" href="style.css">
      </head>
      <body>
      HTML
    return output
  end

  ##
  # Creates all necessary ending HTML code.
  def HTMLCreator.end_html
    return <<-HTML
    </body>
      </html>
      HTML
  end
  
end
