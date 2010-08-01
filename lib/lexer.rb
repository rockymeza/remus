require 'strscan'
require 'lib/token'

module Remus
  module Lexer

    class Lexer < StringScanner
      
      Tokens = {}
      
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
        tokens = ''
        tokens << tokenize( @tokens[:base] )
        tokens
      end
      
      
      def t( type = :plain, *args )
        if args.length == 1; return Remus::Token.const_get( @token_class ).new( args[0], type ); end
        
        return Remus::Token.const_get( @token_class ).new( matched, type )
      end
        
        
      def tokenize( token_array )
        tokens = process_tokens( token_array )
        
        p = ''
        p << _tokenize( tokens ) until eos?
        return p
      end
      
      
      def _tokenize( tokens )
        p = ''
        
        tokens.each do | regexp, token |
          token = [ token ] unless token.is_a? Array
          
          while scan( regexp ) && ! matched.empty?
            if token[0].is_a? String
              p << self.send(token[0])
              break
            elsif token[0].is_a? Hash
              p << Remus.convert( matched, token[0][:lang], @options ).to_s
              break
            end
            
            p << t( token[0] )
            
            token[1..-1].each do | modifier |
              return [ p, :close ] if modifier == :close

              modifier_tokens = process_tokens( @tokens[ modifier ] )
              while a = _tokenize( modifier_tokens )
                a = [ a ] unless a.is_a? Array
                p << a[0]
                break if ( a.length > 1 && a[1] == :close ) || eos?
              end
            end
          end
        end
        getch && p << t if p == ''
        p
      end
      
      
      def process_tokens( token_array )
        tokens = token_array[0]
        
        if token_array.length > 1
          token_array[1].each do | key |
            if key.is_a? Array
              require "lang/#{key[0]}"
              lexer_class = Remus.classify( key[0] )
              foreign_tokens = Remus::Lexer.const_get( lexer_class )::Tokens
              tokens.merge!( foreign_tokens.delete( key[1] )[0] )
              @tokens.merge!( foreign_tokens )
            else
              tokens.merge!( @tokens[ key ][0] )
            end
          end
        end
        tokens
      end
      
      
      # if the lexer wishes to output something after tokenizing
      def after
        ''
      end
      
      
      def initialize( string, options = {} )
        defaults = { :token_class => :html }
        options = defaults.merge options
        @token_class = Remus.classify( options[:token_class] )
        require "lib/tokens/#{options[:token_class]}"
        
        super string
        @options = options
        @output = String.new
        @subregions = Hash.new
        setup
      end
      
      
      # this is odd, maybe I don't understand how class variables work
      # 
      def setup
        @tokens = self.class::Tokens
      end
    end
    
    
    # An empty Lexer class, basically returns the string untouched
    # This is the default Lexer.
    class PlainText < Lexer
      Tokens = {
        :base => [ {
          /.*/m => [ :plain ]
        } ]
      }
    end
  
  end
end
