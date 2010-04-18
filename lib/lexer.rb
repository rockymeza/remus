require 'strscan'
require 'lib/token'

module Remus
  module Lexer

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
        if args.length == 1; return Remus::Token.const_get( @token_class ).new( args[0], type ); end
        
        return Remus::Token.const_get( @token_class ).new( matched, type )
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
      
      
      def initialize( string, options = { :token_class => :html } )
        @token_class = Remus.classify( options[:token_class] )
        require "lib/tokens/#{options[:token_class]}" unless Remus::Token.const_defined?( @token_class )
        
        super string
        @options = options
        @output = String.new
        @subregions = Hash.new
        setup
      end
      
      
      # setup should define the @tokens variable
      def setup
        @tokens = {
          :base => [ {
            /.*/m => [ :plain ]
          } ]
        }
      end
    end
    
    
    # An empty Lexer class, basically returns the string untouched
    # This is the default Lexer.
    class PlainText < Lexer
    end
  
  end
end
