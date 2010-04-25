module Remus
  module Lexer
    
    class Js < Lexer
      Tokens = {
        :base => [ {
          # comment will match /* ... */ or // comment
          /\/\*.*?\*\//m => :comment,
          /\/\/.*/ => :comment,
          
          # keyword
          /if|else|end|true|false|var|function|&&|document|window|this|\|\|/ => :keyword,
          
          # operator
          /\+|-|!|\={1,3}|!\={1,2}|\%/ => :operator,
          /\?/ => [ :operator, :ternary ],
          
          # string will match "...", '...'
          /(["']).*?\1/i => :string,
          
          # function
          /(\.)?[a-z][a-z0-9_-]*\(|\$\(/i => [ :function, :function ],
          
          # property
          /\.[a-z][a-z0-9_-]*/ => :property,
          
          # number will match 12, 12.1
          /[0-9]+(\.)?[0-9]*|\.[0-9]*/i => :number,
          
          # variable
          /\w+[\s]*:|(\$)?[a-z0-9_-]+/i => :variable,
          
          # punctuation
          /;|,/ => :punctuation,
          /\(/ => [ :punctuation, :parenthesis ],
          /\{/ => [ :punctuation, :brace ],
          
          # plain
          /\s*/ => :plain
        } ],
        :function => [ {
          /\)/ => [ :function, :close ]
        }, [ :base ] ],
        :parenthesis => [ {
          /\)/ => [ :punctuation, :close ]
        }, [ :base ] ],
        :brace => [ {
          /\}/ => [ :punctuation, :close ]
        }, [ :base ] ],
        :ternary => [ {
          /:/ => [ :operator, :close ]
        }, [ :base ] ]
      }
    end
  
  end
end
