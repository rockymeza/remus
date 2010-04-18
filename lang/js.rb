module Remus
  
  class Js < Lexer
    
    def setup
      @tokens = {
        :base => [ {
          # comment will match /* ... */ or // comment
          /\/\*.*?\*\//m => :comment,
          /\/\/.*/ => :comment,
          
          # keyword
          /if|else|end|true|false|var|function|&&|document|window|this|\|\|/ => :keyword,
          
          # operator
          /\+|-|!|\={1,3}|!\={1,2}|\?|:|\%/ => :operator,
          
          # string will match "...", '...'
          /(["']).*?\1/i => :string,
          
          # number will match 12, 12.1
          /[0-9\.]+/i => :number,
          
          # function
          /[a-z][a-z0-9_-]*\(|\$\(/i => [ :function, :function ],
          
          # punctuation will match }
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
        }, [ :base ] ]
      }
    end
    
  end
  
end
