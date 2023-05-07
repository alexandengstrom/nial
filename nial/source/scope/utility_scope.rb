require_relative "type_scope"

class UtilityScope < TypeScope
  def initialize(name, position)
    super(name, nil, position)
  end

  def set_constant(identifier, value)
    @variables[identifier.value] = value
    return value
  end
end
