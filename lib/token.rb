class Token < String
  
  
  attr_reader :type
  
  attr_reader :special
  
  def initialize( text, type = :plain, special = nil )
    super text
    @type = type
  end

end
