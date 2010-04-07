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
      _subregionize
      
      tokens = ''
      tokens << tokenize until eos?
      tokens
    end
    
    def t( type = :plain )
      return Token.new( matched, type )
    end
    
    def _subregionize
      @subregions.each do | lang, regex |
        if subregions = string.scan( regex )
          subregions.each do |subregion|
            new_subregion = Remus.convert( subregion[1], lang ).to_s
            string.sub!( subregion[1], no_color( new_subregion ) )
          end
        end
      end
    end
      
    def tokenize
      if scan( /@@@REMUSNOCOLOR@@@[\w\W]*?@@@REMUSNOCOLOR@@@/ )
        puts 'asdfasd'
        return t( :nocolor )
      end
      
      @tokens.each do | key, value |
        if value.is_a? Hash
          if @opened
            
            if value[:closer].is_a? Regexp
              if value.has_key?( :on_open ) && scan( value[:on_open] )
                return t( key )
              end
              if scan( value[:closer] )
                @opened = false
                return t( key )
              end
            else
              if value[:on_open] && scan( value[:on_open] )
                @opened = false if value.has_key? :closer
                return t( key )
              end
            end
          
          else # else @opened
            
            if value[:opener].is_a? Regexp
              if value.has_key?( :on_closed ) && scan( value[:on_closed] )
                return t( key )
              end
              if scan( value[:opener] )
                @opened = true
                return t( key )
              end
            else
              if value.has_key?( :on_closed ) && scan( value[:on_closed] )
                @opened = true if value.has_key? :opener
                return t( key )
              end
            end
            
          end # end @opened
          if value.has_key?( :catch_all ) && scan( value[:catch_all] )
            return t( key )
          end
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
    
    
    def initialize( string )
      super string
      @output = String.new
      @subregions = Hash.new
    end
    
    
    def no_color( string )
      return '@@@REMUSNOCOLOR@@@' + string + '@@@REMUSNOCOLOR@@@'
    end
  end
  
end
