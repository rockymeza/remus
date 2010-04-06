require 'strscan'
require 'lib/token'

module Remus

  class Lexer < StringScanner
    
    attr_accessor :tokens
    
    def to_s
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
    
    def t( type = :plain )
      return Token.new( matched, type )
    end
    
    def tokenize
      @tokens.each do | key, value |
        if value.is_a? Hash
          if @opened
            
            if value[:closer].is_a? Regexp
              if value[:on_open] && scan( value[:on_open] )
                return t( key )
              end
              if scan( value[:closer] )
                @opened = false
                return t( key )
              end
            else
              if value[:on_open] && scan( value[:on_open] )
                @opened = false if value[:closer]
                return t( key )
              end
            end
          
          else # else @opened
            
            if value[:opener].is_a? Regexp
              if value[:on_closed] && scan( value[:on_closed] )
                return t( key )
              end
              if scan( value[:opener] )
                @opened = true
                return t( key )
              end
            else
              if value[:on_closed] && scan( value[:on_closed] )
                @opened = true if value[:opener]
                return t( key )
              end
            end
            
          end # end @opened
        else # else value.is_a? Hash
          
          if scan( value )
            return t( key )
          end
          
        end # end value.is_a? Hash
      end
      getch && t
    end
    
    
    # if the lexer wishes to output something after tokenizing
    def after
      ''
    end
    
    
    def output
      return @output
    end
    
    
    def initialize( string )
      super string
      @output = String.new
      @tokens = {
        :plain => /.*/
      }
    end
    
    
  end
  
end
