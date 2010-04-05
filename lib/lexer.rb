require 'strscan'
require 'lib/token'

module Remus

  class Lexer
    # Lexer that tokenizes the input
    
    # The string to be tokenized
    attr_accessor :string
    
    def self.convert( string )
      lexer = self.new( string )
      
      lexer.before
      lexer.tokenize
      lexer.after
      
      return lexer.output
    end
    
    
    def before
    end
    
    
    def tokenize
      @output << Token.new( @string )
    end
    
    
    def after
    end
    
    
    def output
      return @output
    end
    
    
    def initialize( string )
      @string = string
      @output = String.new
    end
    
    
  end
  
end
