##
# This class is responsible for creating an XML file that stores all data about
# a project if the user wants to create documentation for their project.
class XMLWriter
  @@content = ""
  @@type_content = ""
  @@utility_content = ""
  @@indent = 0
  @@currently_inside = false

  ##
  # Initializes a new XML document to the buffer.
  def XMLWriter.init
    @@content += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE classes SYSTEM \"classes.dtd\">\n"
    @@content += "<documentation>\n"
    @@type_content += "  <types>\n"
    @@utility_content += "  <utilities>\n"
    @@indent += 4
  end

  ##
  # Writes the buffer to the actual file.
  def XMLWriter.save
    @@type_content += "  </types>\n"
    @@utility_content += "  </utilities>\n"
    @@content += @@type_content + @@utility_content
    @@content += "</documentation>"

    input_file_path = File.expand_path(ARGV[1])
    path = File.join(File.dirname(input_file_path), "docs/xml/docs.xml")
    File.write(path, @@content)
  end

  ##
  # Open a new type tag.
  def XMLWriter.new_class(name, description, extend)
    @@currently_inside = :type
    @@type_content += " " * @@indent
    @@type_content += "<type name=\"#{name}\""
    if extend
      @@type_content += " extend=\"#{extend.value}\""
    end
    @@type_content += ">\n"
    @@indent += 2
    @@type_content += " " * @@indent
    @@type_content += "<description>"
    @@type_content += "#{description}"
    @@type_content += "</description>\n"
  end

  ##
  # Open a new utility tag.
  def XMLWriter.new_utility(name, description)
    @@currently_inside = :utility
    @@utility_content += " " * @@indent
    @@utility_content += "<utility name=\"#{name}\">\n"
    @@indent += 2
    @@utility_content += " " * @@indent
    @@utility_content += "<description>"
    @@utility_content += "#{description}"
    @@utility_content += "</description>\n"
  end

  ##
  # Close an utility tag.
  def XMLWriter.close_utility
    @@indent -= 2
    @@utility_content += " " * @@indent
    @@utility_content += "</utility>\n"
  end

  ##
  # Close a type tag.
  def XMLWriter.close_class
    @@indent -= 2
    @@type_content += " " * @@indent
    @@type_content += "</type>\n"
  end

  ##
  # Open attributes tag.
  def XMLWriter.open_attributes
    content = " " * @@indent
    content += "<attributes>\n"
    @@indent += 2

    if @@currently_inside == :type
      @@type_content += content
    else
      @@utility_content += content
    end
  end

  ##
  # Close attributes tag.
  def XMLWriter.close_attributes()
    @@indent -= 2
    content = " " * @@indent
    content += "</attributes>\n"

    if @@currently_inside == :type
      @@type_content += content
    else
      @@utility_content += content
    end
  end

  ##
  # Add a attribute tag.
  def XMLWriter.add_attribute(identifier, description)
    content = " " * @@indent
    content += "<attribute name=\"#{identifier}\">\n"
    @@indent += 2
    content += " " * @@indent
    content += "<description>"
    content += "#{description}"
    content += "</description>\n"
    @@indent -= 2
    content += " " * @@indent
    content += "</attribute>\n"

    if @@currently_inside == :type
      @@type_content += content
    else
      @@utility_content += content
    end
    
  end

  ##
  # Open methods tags.
  def XMLWriter.open_methods
    content = " " * @@indent
    content += "<methods>\n"
    @@indent += 2

    if @@currently_inside == :type
      @@type_content += content
    else
      @@utility_content += content
    end
  end

  ##
  # Add a method tag.
  def XMLWriter.add_method(name, description, parameters, type=:type)
    content = " " * @@indent
    content += "<method name=\"#{name}\">\n"
    @@indent += 2
    content += " " * @@indent
    content += "<description>"
    content += description
    content += "</description>\n"
    content += self.add_parameters(parameters)
    @@indent -= 2
    content += " " * @@indent
    content += "</method>\n"

    if @@currently_inside == :type
      @@type_content += content
    else
      @@utility_content += content
    end
    
  end

  ##
  # Add parameters to the method.
  def XMLWriter.add_parameters(parameters)
    content = " " * @@indent
    content += "<parameters>\n"
    @@indent += 2
    parameters.each { |param|
      content += " " * @@indent
      content += "<parameter name=\"#{param[0].value}\" copy=\"#{param[1]}\"/>\n"
    }
    @@indent -= 2
    content += " " * @@indent
    content += "</parameters>\n"

    return content
  end

  ##
  # Close the methods tag.
  def XMLWriter.close_methods
    @@indent -= 2
    content = " " * @@indent
    content += "</methods>\n"

    if @@currently_inside == :type
      @@type_content += content
    else
      @@utility_content += content
    end
  end
end
