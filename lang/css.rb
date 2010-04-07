module Remus
  
  class Css < Lexer
    
    def initialize( string )
      super string
      
      @tokens = {
        # comment will match /* ... */
        :comment => /\/\*.*\*\//,
        
        # keyword
        :keyword => /!important|inherit/,

        # punctuation will match }
        :punctuation => { :on_open => /\}/, :on_closed => /\{/, :opener => true, :closer => true },
        
        # attribute will match color:, and ;
        :attribute => { :on_open => /[\w-]+:|;/ },
        
        # string will match "...", '...', and url(...)
        :string => { :on_open => /(["']).*?\1|url\(.*?\)/ },
        
        # number will match 12, 12px, 12em, 12%, #123asd, #fff
        :number => { :on_open => /[0-9\.\%]+(?:px|em)?{0,1}|#([a-f0-9]{6}|[a-f0-9]{3})/i },
        
        # identifier will match body, div#id, span.class, p#id.class, #id, .class
        :identifier => { :on_closed => /[\w\.#]+/ },
        
        # plain
        :plain => { :on_open => /[\w-]+/, :catch_all => /[,\s]+/ }
      }
    end
    
  end
  
end
