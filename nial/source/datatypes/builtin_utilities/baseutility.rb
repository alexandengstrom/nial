class BaseUtility
  @@attributes = Hash.new
  
  def BaseUtility.get_attribute(attribute, scope, position)
    if @@attributes.has_key?(attribute.value)
      return @@attributes[attribute.value].copy(scope, position)
    end
    return ConstantNotDefined.new(self.name, attribute, scope, position)
  end

  def BaseUtility.display(_,_)
    return "<#{self.class} at #{self.to_s.split(":")[1][0..-2]}>"
  end
end
