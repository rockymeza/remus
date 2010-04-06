module Remus
  
  class Html < Lexer
    
    def tokenize
      if @opened
        case
          when scan( />/ ) || scan( /\/>/ )
            @opened = false
            return Token.new( matched, :identifier )
          when scan( /\w+=/ )
            return Token.new( matched, :attribute )
          when scan( /".*?"/ )
            return Token.new( matched, :string )
        else
          scan /\s/
          return Token.new( matched, :nocolor )
        end
      else
        case
          when peek(1) == '<'
            if scan /<!--.*?-->/
              return Token.new( matched, :comment )
            elsif scan /<\/\w+>/
              return Token.new( matched, :identifier )
            elsif scan /<\w+>/
              return Token.new( matched, :identifier)
            else
              scan /<\w+/
              @opened = true
              return Token.new( matched, :identifier )
            end
        else
          scan /[^<]+/
          return Token.new( matched )
        end
      end
    end
    
  end
  
end
