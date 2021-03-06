module Remus::Lexer
    
    class Html < Lexer
      Tokens = {
        :base => [ {
          # comment will match <!-- ... -->
          /<!--.*?-->/m => :comment,
          
          /<style/i => [ :identifier, :tag, :css ],
          /<script/i => [ :identifier, :tag, :js ],
          
          # identifier will match </p>, <br />
          /<[a-z0-9]+>|<\/[a-z0-9]+>/ => :identifier,
          
          # identifier will match <p and open the :tag
          /<\w+/ => [ :identifier, :tag ],
          
          # plain
          /[^<&]+/ => :plain,
        } ],
        :tag => [ {
          # variable will match id=
          /\w+=/ => :variable,
          
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
