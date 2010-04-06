require 'strscan'
require 'lib/token'

module Remus

  class Lexer < StringScanner
    # Lexer that tokenizes the input
    
    
    def convert
      @output << before
      @output << main
      @output << after
    end
    
    
    # if the lexer wishes to output something prior to tokenizes
    def before
      ''
    end
    
    
    def main
      tokens = ''
      tokens << tokenize until eos?
      tokens
    end
    
    
    def tokenize
      return Token.new( getch )
    end
    
    
    # if the lexer wishes to output something after tokenizing
    def after
      ''
    end
    
    
    def output
      return @output
    end
    
    
    def initialize( string )
      @output = String.new
      super string
    end
    
    
  end
  
end
