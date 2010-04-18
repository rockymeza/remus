module Remus
  module Token
    
    class Token < String
      
      # The type of token that this is
      # e.g. :plain, :constant, :literal, :number, :keyword, etc.
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
