module Remus
  module Lexer
    
    class Php < Lexer
      
      def setup
        @tokens = {
          :base => [ {
            /<\?(php)?/ => [ :keyword, :php ]
          }, [ [ :html, :base ] ] ],
          :php => [ {
            /\?>/ => [ :keyword, :close ],
            
            /\$[a-z_][a-z0-9_]*/ => :variable,
            
            /=|\+/ => :operator,
          } ],
        }
      end
      
    end
    
  end
end
