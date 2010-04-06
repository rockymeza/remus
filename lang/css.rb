module Remus
  
  class Css < Lexer
    
    def initialize( string )
      super string
      
      @tokens = {
        # comments will match /* ... */
        :comment => /\/\*.*\*\//,
        
        # keywords
        :keyword => /!important|inherit/,

        # punctuation will match }
        :punctuation => { :on_open => /}/, :on_closed => /{/, :opener => true, :closer => true },
        
        # attributes will match color:, and ;
        :attribute => { :on_open => /[\w-]+:|;/ },
        
        # strings will match "...", '...', and url(...)
        :string => { :on_open => /(["']).*?\1|url\(.*?\)/ },
        
        # numbers will match 12, 12px, 12em, 12%, #123asd, #fff
        :number => { :on_open => /[0-9\.\%]+(?:px|em)?{0,1}|#([a-f0-9]{6}|[a-f0-9]{3})/i },
        
        # identifier will match body, div#id, span.class, p#id.class, #id, .class
        :identifier => { :on_closed => /[\w\.#]+/ },
        
        # plains
        :plain => { :on_open => /[\w-]+/, :catch_all => /[,\s]+/ }
      }
    end
    
  end
  
end
