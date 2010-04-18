module Remus
  
  class Css < Lexer
    
    def initialize( string )
      super string
      
      @tokens = {
        :base => {
          # punctuation will match { and open a definition
          /\{/ => [ :punctuation, :definition ],
          
          # identifier will match body, div#id, span.class, p#id.class, #id, .class
          /[\w\.#]+/ => :identifier,
        },
        :catch_all => {
          # comment will match /* ... */
          /\/\*[\s\S]*?\*\// =>  :comment,
          
          # keyword
          /!important|inherit/ => :keyword,
          
          # plain
          /[,\s]+/ => :plain,
        },
        :definition => {
          # attribute will match color:, and ;
          /[\w-]+:|;/i => :attribute,
          
          #punctuation will match } and close out
          /\}/ => [ :punctuation, :close ],
          
          # string will match "...", '...', and url(...)
          /(["']).*?\1|url\(.*?\)/i => :string,
          
          # number will match 12, 12px, 12em, 12%, #123asd, #fff
          /[0-9\.\%]+(?:px|em)?{0,1}|#([a-f0-9]{6}|[a-f0-9]{3})/i => :number,
          
          # plain
          /[\w-]+/i => :plain,
        }
      }
    end
    
  end
  
end
