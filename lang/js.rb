module Remus
  
  class Js < Lexer
    
    def initialize( string )
      super string
      
      @tokens = {
        # comment will match /* ... */
        :comment => /\/\*[\s\S]*?\*\/|\/\/.*/,
        
        # function
        :function => { :nestable => [ /[a-z][a-z0-9_-]*\(|\$\(/i, /\)/ ] },
        
        # keyword
        :keyword => /if|else|end|true|false|var|function|&&|document|window|this|\|\|/,

        # punctuation will match }
        :punctuation => /\(|\)|\{|\}/,
        
        # attribute will match color:, and ;
        :attribute => /[\w_-]+:/i,
        
        # operator
        :operator => /\+|-|\=|\?|:|\%/,
        
        # string will match "...", '...', and url(...)
        :string => /(["']).*?\1/i,
        
        # number will match 12, 12px, 12em, 12%, #123asd, #fff
        :number => /[0-9\.]+/i,
        
        # identifier will match body, div#id, span.class, p#id.class, #id, .class
        #:identifier => { :on_closed => /[\w\.#]+/ },
        
        # plain
        #:plain => { :on_open => /[\w-]+/i, :catch_all => /[,\s]+/ }
      }
    end
    
  end
  
end
