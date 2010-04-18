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
    
    
    # if the lexer wishes to output something prior to tokenizes
    def before
      ''
    end
    
    
    def main
      _subregionize
      
      tokens = ''
      tokens << tokenize until eos?
      tokens
    end
    
    def t( type = :plain, *args )
      if args.length == 1; return Token.new( args[0], type ); end
      
      return Token.new( matched, type )
    end
    
    def _subregionize
      @subregions.each do | lang, regex |
        if subregions = string.scan( regex )
          subregions.each do |subregion|
            new_subregion = Remus.convert( subregion[1], lang ).to_s
            #string.sub!( subregion[1], no_color( new_subregion ) )
            string.sub!( subregion[1], new_subregion )
          end
        end
      end
    end
      
    def tokenize
      return _tokenize( @tokens[:base] )
    end
    
    
    def _tokenize( tokens )
      p = ''
      
      #if scan( /@@@REMUSNOCOLOR@@@[\s\S]*?@@@REMUSNOCOLOR@@@/ )
      #  p << t( :nocolor )
      #end
      
      tokens.merge( @tokens[:catch_all] || Hash.new ).each do | regexp, token |
        token = [ token ] unless token.is_a? Array
        
        if scan( regexp )
          p << t( token[0] )
          
          if token.length > 1
            return [ p, :close ] if token[1] == :close
            
            while a = _tokenize( @tokens[ token[1] ] )
              a = [ a ] unless a.is_a? Array
              p << a[0]
              break if a.length > 1 && a[1] == :close
            end
          end
        end
      end
      getch && t if p == ''
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
    end
    
    
    #def no_color( string )
    #  return '@@@REMUSNOCOLOR@@@' + string + '@@@REMUSNOCOLOR@@@'
    #end
  end
  
end
