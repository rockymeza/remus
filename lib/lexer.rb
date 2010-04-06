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
      if @opened
        case
          when peek(1) == '>'
            @opened = false
            return Token.new( ( scan( />/ ) ), :identifier )
          when scan( /\w+=/ )
            return Token.new( matched, :attribute )
          when scan( /".*?"/ )
            return Token.new( matched, :string )
        else
          scan /\s/
          return Token.new( matched, :nocolor )
        end
      else
        case
          when peek(1) == '<'
            if scan /<\/\w+>/
              return Token.new( matched, :identifier )
            elsif scan /<\w+>/
              return Token.new( matched, :identifier)
            else
              scan /<\w+/
              @opened = true
              return Token.new( matched, :identifier )
            end
        else
          scan /[^<]+/
          return Token.new( matched )
        end
      end
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
