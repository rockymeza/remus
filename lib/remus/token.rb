module Remus::Token
  
  ##
  # This is an abstract token class.
  # 
  #
  # A Token class should provide support for all of the
  # following types:
  # 
  # 1. plain -- the <tt>Hello World</tt> in <tt><span>Hello World</span></tt> for HTML
  # 2. keyword -- +if+, +else+, +elsif+, +end+, +class+, +module+ in Ruby
  # 3. reserved -- +true+, +false+ in JavaScript
  # 4. comment -- <tt>/* comment */</tt> in CSS
  # 5. string -- <tt>"Hello World!"</tt> in PHP
  # 6. number -- +4+ in Ruby
  # 7. function -- <tt>strip_tags()</tt> in PHP
  # 8. property -- the +.length+ in <tt>"Hello World".length</tt> in Javascript
  # 9. operator -- <tt>+</tt>, +-+, <tt>&&</tt> in Ruby
  # 10. identifier -- <tt><p></tt> in HTML
  # 11. variable -- <tt>$var</tt> in PHP
  # 12. punctuation -- nonoperator punctuation marks such as <tt>;</tt> in PHP
  class Token < String

    # The type of the token
    attr_reader :type
    
    # Takes a string and a type, wraps the string
    # according to the wrap function and then returns
    # it.
    def initialize( text, type = :plain )
      @type = type
      @text = text
      super wrap
    end
    
    # wrap takes a string and colors it.
    #
    # the wrap function should be able to handle all of the
    # token types.
    def wrap
      @text
    end
  end
    
end
