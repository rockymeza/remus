module Remus
  module Token
    
    class Token < String
=begin
A Token class should provide support for all of the
following types:

1. plain -- the Hello World in <span>Hello World</span> for HTML
2. keyword -- if, else, elsif, end, class, module in Ruby
3. reserved -- true, false in JavaScript
4. comment -- /* comment */ in CSS
5. string -- "Hello World!" in PHP
6. number -- 4 in Ruby
7. function -- strip_tags() in PHP
8. property -- the .length in "Hello World".length in Javascript
9. operator -- +, -, && in Ruby
10. identifier -- <p> in HTML
11. variable -- $var in PHP
12. punctuation -- nonoperator punctuation marks such as ; in PHP

=end
      
      attr_reader :type
      
      def initialize( text, type = :plain )
        @type = type
        @text = text
        super wrap
      end
      
      # wrap should return a string
      def wrap
        @text
      end
    end
    
  end
end
