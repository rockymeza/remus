module Remus
  
  class Html < Lexer
  
    def initialize( string )
      super string
      
      @tokens = {
        :base => {
          # comment will match <!-- ... -->
          /<!--[\s\S]*?-->/ => :comment,
          
          # identifier will match </p>, <br />
          /<\/[a-z0-9]+>|<[a-z0-9]+\s\/>/ => :identifier,
          
          # identifier will match <p and open the :tag
          /<\w+/ => [ :identifier, :tag ],
          
          # plain
          /[^<&]+/ => :plain,
        },
        :tag => {
          # attribute will match id=
          /\w+=/ => :attribute,
          
          # string will match "...", '...'
          /(["']).*?\1/ => :string,
          
          # identifier will match > and close out
          />|\/>/ => [ :identifier, :close ],
          
          # plain
          /\s+/ => :plain,
        }
      }
      
      # subregions are for embedded languages like JS and CSS
      # I know it's kind of a lame syntax to have to find three groups, but that's the only way I could get it to work
      @subregions = {
        :css => /(<style.*?>)([\s\S]*?)(<\/style>)/i
      }
    end
    
  end
  
end
