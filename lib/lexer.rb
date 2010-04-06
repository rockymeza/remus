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
      case
        when peek(1) == '<'
          if scan /<\/\w+>/
            return Token.new( matched, :tag )
          elsif scan /<\w+>/
            return Token.new( matched, :tag)
          else
            scan /<\w+/
            @opened = true
            return Token.new( matched, :tag )
          end
        when peek(1) == '>'
          if @opened
            @opened = false
            return Token.new( ( scan( />/ ) ), :tag )
          end
        when scan( /\w+=/ )
          return Token.new( matched, :attribute ) if @opened
          return Token.new( matched, :plain )
        when scan( /".*?"/ )
          return Token.new( matched, :string ) if @opened
          return Token.new( matched, :plain )
      end
      getch
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
