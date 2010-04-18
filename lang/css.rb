module Remus
  module Lexer
    
    class Css < Lexer
      
      def setup
        @tokens = {
          :base => [ {
            # punctuation will match { and open a definition
            /\{/ => [ :punctuation, :definition ],
            
            # identifier will match body, div#id, span.class, p#id.class, #id, .class
            /[a-z0-9\.#_-]+|:[a-z0-9_-]+/i => :identifier,
          }, [ :global ] ],
          :global => [ {
            # comment will match /* ... */
            /\/\*.*?\*\//m =>  :comment,
            
            # keyword
            /!important|inherit/ => :keyword,
            
            # plain
            /[,\s]+/ => :plain,
          } ],
          :definition => [ {
            # variable will match color:, and ;
            /[\w-]+:|;/i => :variable,
            
            #punctuation will match } and close out
            /\}/ => [ :punctuation, :close ],
            
            # string will match "...", '...', and url(...)
            /(["']).*?\1|url\(.*?\)/i => :string,
            
            # number will match 12, 12px, 12em, 12%, #123asd, #fff
            /[0-9\.\%]+(?:px|em)?{0,1}|#([a-f0-9]{6}|[a-f0-9]{3})/i => :number,
            
            # plain
            /[\w-]+/i => :plain,
          }, [ :global ] ]
        }
      end
      
    end
    
  end
end
