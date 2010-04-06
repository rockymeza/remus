class Token < String
  
  # The type of token that this is
  # e.g. :plain, :constant, :literal, :number, :keyword, etc.
  attr_reader :type
  
  # A special would be relevant for something like an opening parentheses
  # e.g. :opener, :closer
  attr_reader :special
  
  def initialize( text, type = :plain, special = nil )
    @type = type
    @text = text
    super wrap
  end
  
  def wrap
    case type
      when :string
        '<span class="string">' + @text + '</span>'
      when :tag
        '<span class="tag">' + @text + '</span>'
    else
      @text
    end
  end
  
end
