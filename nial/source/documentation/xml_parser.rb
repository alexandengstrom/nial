require "rexml/document"

##
# Responsible for parsing the XML file created by XMLWriter to be able to
# create other type of documentation from that.
class XMLParser

  ##
  # Parses the XML file and returns a Hash containing all data.
  def XMLParser.parse
    output = Hash.new
    output["types"] = Array.new
    output["utilities"] = Array.new
    
    input_file_path = File.expand_path(ARGV[1])
    path = File.join(File.dirname(input_file_path), "docs/xml/docs.xml")
    
    xml = File.read(path)
    doc = REXML::Document.new(xml)

    doc.elements.each("documentation/types/type") do |type|
      current_type = Hash.new
      current_type["name"] = type.attributes["name"]
      if type.attributes.has_key?("extend")
        current_type["extends"] = type.attributes['extend']
      end
      current_type["description"] = type.elements['description'].text
      current_type["attributes"] = Array.new

      attributes = type.elements['attributes']
      
      if  !attributes.elements.empty?
        attributes.elements.each("attribute") do |attribute|
          current_attribute = Hash.new
          current_attribute["name"] = attribute.attributes['name']
          current_attribute["description"] = attribute.elements['description'].text
          current_type["attributes"] << current_attribute
        end
      end

      current_type["methods"] = Array.new

      methods = type.elements['methods']
      if !methods.elements.empty?
        methods.elements.each("method") do |method|
          current_method = Hash.new
          current_method["name"] = method.attributes['name']
          current_method["description"] = method.elements['description'].text

          current_method["parameters"] = Array.new
          parameters = method.elements['parameters']
          if !parameters.elements.empty?
            parameters.elements.each("parameter") do |parameter|
              current_parameter = Hash.new
              current_parameter["name"] = parameter.attributes["name"]
              current_parameter["copy"] = parameter.attributes["copy"]
              current_method["parameters"] << current_parameter
            end
          end
          current_type["methods"] << current_method
        end
        
      end
      output["types"] << current_type
    end


    doc.elements.each("documentation/utilities/utility") do |utility|
      current_utility = Hash.new
      current_utility["name"] = utility.attributes["name"]
      current_utility["description"] = utility.elements['description'].text
      current_utility["attributes"] = Array.new

      attributes = utility.elements['attributes']
      
      if  !attributes.elements.empty?
        attributes.elements.each("attribute") do |attribute|
          current_attribute = Hash.new
          current_attribute["name"] = attribute.attributes['name']
          current_attribute["description"] = attribute.elements['description'].text
          current_utility["attributes"] << current_attribute
        end
      end

      current_utility["methods"] = Array.new

      methods = utility.elements['methods']
      if !methods.elements.empty?
        methods.elements.each("method") do |method|
          current_method = Hash.new
          current_method["name"] = method.attributes['name']
          current_method["description"] = method.elements['description'].text

          current_method["parameters"] = Array.new
          parameters = method.elements['parameters']
          if !parameters.elements.empty?
            parameters.elements.each("parameter") do |parameter|
              current_parameter = Hash.new
              current_parameter["name"] = parameter.attributes["name"]
              current_parameter["copy"] = parameter.attributes["copy"]
              current_method["parameters"] << current_parameter
            end
          end
          current_utility["methods"] << current_method
        end
        
      end
      output["utilities"] << current_utility
    end  
    return output
  end
end
