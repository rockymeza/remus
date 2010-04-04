require 'strscan'
require 'lib/token'

module Remus

  class Lexer
    ##| abstract class
    attr_reader :string
    
    def self.convert( string )
      lexer = self.new( string )
      
      lexer.before
      lexer.main
      lexer.after
      
      return lexer.output
    end
    
    def before
    end
    
    def main
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
