require 'strscan'
require 'lib/token'

module Remus
  module Lexer

    class Lexer < StringScanner
      
      @@tokens = {}
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
        if args.length == 1; return Remus::Token.const_get( @token_class ).new( args[0], type ); end
        
        return Remus::Token.const_get( @token_class ).new( matched, type )
      end
        
        
      def tokenize
        return _tokenize( @tokens[:base] )
      end
      
      
      def _tokenize( token_array )
        p = ''
        
        tokens = token_array[0]
        
        if token_array.length > 1
          token_array[1].each do | key |
            if key.is_a? Array
              require "lang/#{key[0]}"
              lexer_class = Remus.classify( key[0] )
              tokens.merge!( Remus::Lexer.const_get( lexer_class ).tokens[ key[1] ][0] )
            else
              tokens.merge!( @tokens[ key ][0] )
            end
          end
        end
        
        tokens.each do | regexp, token |
          token = [ token ] unless token.is_a? Array
          
          while scan( regexp ) && ! matched.empty?
            if token[0].is_a? Hash
              p << Remus.convert( matched, token[0][:lang], @options ).to_s
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
      
      
      def initialize( string, options = {} )
        @token_class = Remus.classify( options[:token_class] )
        require "lib/tokens/#{options[:token_class]}"
        
        super string
        @options = options
        @output = String.new
        @subregions = Hash.new
        setup
      end
      
      
      def self.tokens
        @@tokens
      end
      
      
      # this is odd, maybe I don't understand how class variables work
      # 
      def setup
        @tokens = @@tokens
      end
    end
    
    
    # An empty Lexer class, basically returns the string untouched
    # This is the default Lexer.
    class PlainText < Lexer
      @@tokens = {
        :base => [ {
          /.*/m => [ :plain ]
        } ]
      }
    end
  
  end
end
