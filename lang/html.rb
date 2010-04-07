module Remus
  
  class Html < Lexer
  
    def initialize( string )
      super string
      
      @tokens = {
        # comment will match <!-- ... -->
        :comment => /<!--.*?-->/,
        
        # attribute will match id=
        :attribute => { :on_open => /\w+=/ },
        
        # string will match "...", '...'
        :string => { :on_open => /(["']).*?\1/ },
        
        # identifier will match <p>, </p>, <br />, <div id="blah">
        :identifier => { :on_closed => /<\/\w+>|<\/\w+>|<\w+\s\/>/, :opener => /<\w+/, :closer => />|\/>/ },
        
        # plain
        :plain => { :on_open => /\s+/, :on_close => /[^<]+/ }
      }
      
      # subregions are for embedded languages like JS and CSS
      @subregions = {
        :css => /(<style.*?>)([\w\W]*?)(<\/style>)/
      }
    end
    
  end
  
end
