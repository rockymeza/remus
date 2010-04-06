module Remus
  
  class Html < Lexer
  
    def initialize( string )
      super string
      
      @tokens = {
        # comments will match <!-- ... -->
        :comment => /<!--.*?-->/,
        
        # attributes will match id=
        :attribute => { :on_open => /\w+=/ },
        
        # strings will match "...", '...'
        :string => { :on_open => /(["']).*?\1/ },
        
        # identifier will match <p>, </p>, <br />, <div id="blah">
        :identifier => { :on_closed => /<\/\w+>|<\/\w+>|<\w+\s\/>/, :opener => /<\w+/, :closer => />|\/>/ },
        
        # plains
        :plain => { :on_open => /\s+/, :on_close => /[^<]+/ }
      }
    end
    
  end
  
end
