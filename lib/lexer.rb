require 'strscan'
require 'lib/token'

module Remus

  class Lexer < StringScanner
    
    attr_accessor :tokens
    
    def convert
      @output << before
      @output << main
      @output << after
    end
    
    def to_s
      @output
    end
    
    
    def dump
      to_s.dump
    end
    
    
    def dump
      to_s.dump
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
    
    
    def t( type = :plain, *args )
      puts matched.dump, type
      if args.length == 1; return Token.new( args[0], type ); end
      
      return Token.new( matched, type )
    end
      
      
    def tokenize
      return _tokenize( @tokens[:base] )
    end
    
    
    def _tokenize( token_array )
      p = ''
      
      if scan( /@@@REMUSNOCOLOR@@@[\w\W]*?@@@REMUSNOCOLOR@@@/ )
        p << t( :nocolor )
      end
      tokens = token_array[0]
      
      if token_array.length > 1
        token_array[1].each do | key |
          tokens.merge!( @tokens[ key ][0] )
        end
      end
      
      tokens.each do | regexp, token |
        token = [ token ] unless token.is_a? Array
        
        if scan( regexp )
          if token[0].is_a? Hash
            p << Remus.convert( matched, token[0][:lang] ).to_s
            break
          end
          
          p << t( token[0] )
          
          token[1..-1].each do | modifier |
            return [ p, :close ] if modifier == :close
            
            while a = _tokenize( @tokens[ modifier ] )
              a = [ a ] unless a.is_a? Array
              p << a[0]
              break if a.length > 1 && a[1] == :close
            end
          end
        end
      end
      getch && p << t if p == ''
      p
    end
    
    
    # if the lexer wishes to output something after tokenizing
    def after
      ''
    end
    
    
    def initialize( string )
      super string
      @output = String.new
      @subregions = Hash.new
      setup
    end
  end
  
end
