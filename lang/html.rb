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
      # I know it's kind of a lame syntax to have to find three groups, but that's the only way I could get it to work
      @subregions = {
        :css => /(<style.*?>)([\w\W]*?)(<\/style>)/i
      }
    end
    
  end
  
end
