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
    send( @type, @text )
  end
  
  def colorize(text, color_code)
    "#{color_code}#{text}\e[0m"
  end

  def nocolor(text); text; end
  def identifier(text); colorize(text, "\e[31m"); end
  def string(text); colorize(text, "\e[32m"); end
  def yellow(text); colorize(text, "\e[33m"); end
  def attribute(text); colorize(text, "\e[34m"); end
  def plain(text); colorize(text, "\e[35m"); end
  def cyan(text); colorize(text, "\e[36m"); end
end
