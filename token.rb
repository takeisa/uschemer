class Token
  attr_accessor :type
  attr_accessor :value

  def initialize(type, value = nil)
    @type = type
    @value = value
  end

  def to_s
    "type:#{@type} value:#{@value}"
  end
end
