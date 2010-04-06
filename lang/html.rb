module Remus
  
  class Html < Lexer
  
    def initialize( string )
      super string
      
      @tokens = {
        # comments will match <!-- ... -->
        :comment => /<!--.*?-->/,
        
        # attributes will match color:, and ;
        :attribute => { :on_open => /\w+=/ },
        
        # strings will match "...", '...'
        :string => { :on_open => /(["']).*?\1/ },
        
        # identifier will match body, div#id, span.class, p#id.class, #id, .class
        :identifier => { :on_closed => /<\/\w+>|<\/\w+>/, :opener => /<\w+/, :closer => />|\/>/ },
        
        # plains
        :plain => { :on_open => /\s+/, :on_close => /[^<]+/ }
      }
    end
    
  end
  
end
