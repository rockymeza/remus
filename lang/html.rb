module Remus
  
  class Html < Lexer
  
    def setup
      @tokens = {
        :base => [ {
          # comment will match <!-- ... -->
          /<!--.*?-->/m => :comment,
          
          /<style/i => [ :identifier, :tag, :css ],
          /<script/i => [ :identifier, :tag, :js ],
          
          # identifier will match </p>, <br />
          /<\/[a-z0-9]+>/ => :identifier,
          
          # identifier will match <p and open the :tag
          /<\w+/ => [ :identifier, :tag ],
          
          # plain
          /[^<&]+/ => :plain,
        } ],
        :tag => [ {
          # attribute will match id=
          /\w+=/ => :attribute,
          
          # string will match "...", '...'
          /(["']).*?\1/m => :string,
          
          # identifier will match > and close out
          />|\/>/ => [ :identifier, :close ],
          
          # plain
          /\s+/ => :plain,
        } ],
        :css => [ {
          /<\/style>/i => [ :identifier, :close ],
          
          /.+?(?=<\/style>)/mi => { :lang => :css },
        } ],
        :js => [ {
          /<\/script>/i => [ :identifier, :close ],
          
          /.+?(?=<\/script>)/mi => { :lang => :js },
        } ],
      }
    end
    
  end
  
end
