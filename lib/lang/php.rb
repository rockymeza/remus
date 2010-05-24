module Remus::Lexer
    
    class Php < Lexer
      Tokens = {
        :base => [ {
          /<\?(php)?/ => [ :keyword, :php ]
        }, [ [ :html, :base ] ] ],
        :php => [ {
          /\?>/ => [ :keyword, :close ],
          
          /\(|\)|;|,/ => :punctuation, # this is so high because it does not allow function
                                             # subregions to close properly
          
          /\/\/.*|#.*/ => :comment,
          /\/\*\*/ => [ :comment, :phpdoc ],
          /\/\*.*?\*\//m => :comment,
          
          # a goto target
          /\w+:/ => :identifier,
          
          /<<<'([a-z]+)'.*?\1(;)?/i => :string, # support for nowdocs included in PHP 5.3.0
          /(<<<([a-z]+|"[a-z]+"))/i => 'php_heredoc',
          
          # thanks to http://www.php.net/manual/en/language.types.integer.php
          # and http://www.php.net/manual/en/language.types.float.php
          /[1-9][0-9]*(\.)?[0-9]*|0[x][0-9a-f]+|0[0-7]*|[0-9]+e(-|\+)?[0-9]/i => :number,
          
          /=|\+|-|\?|:|!|\.|\||&|>|</ => :operator,
          
          /\b(if|else\s*if|foreach|for|while|switch|array)\s*\(/ => [ :reserved, :reserved ],
          
          /\b(else|case|function|class|extends|implements|public|static|new|private|use|\{|\})\b/i => :reserved,
          /\b(goto)\b/ => [ :reserved, :goto ],
          
          /[a-z_][a-z0-9_]*\s*\(/i => [ :function, :function ],
          /\b(echo|return|use)\b/ => :reserved,
          
          /TRUE|FALSE|NULL|E_ERROR|E_ALL|E_STRICT|E_NOTICE|LOCK_EX/ => :keyword,
          
          /[A-Z][A-Za-z0-9_]*/ => :identifier,
        }, [ :variable, :string ] ],
        :variable => [ {
          # thanks to http://www.php.net/manual/en/language.variables.basics.php
          /\$(\{)?[a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*(\})?/i => :variable,
          
          /->/ => [ :reserved, :property ],
          
          /\[|\]/ => :operator,
        } ],
        :basic_variable => [ {
          # thanks to http://www.php.net/manual/en/language.variables.basics.php
          /\$[a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*/i => :variable,
        } ],
        :heredoc_variable => [ {
          /\}/ => [ :string, :close ],
        }, [ :variable, :string ] ],
        :string => [ {
          # thanks to http://dev.pocoo.org/projects/pygments/browser/pygments/lexers/web.py:753-4
          /'[^\\']*(?:\\.[^\\']*)*'|`[^\\`]*(?:\\.[^\\`]*)*`/m => :string,
          /"/ => [ :string, :double_quote ],
        } ],
        :property => [ {
          /[a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*/i => [ :property, :close ],
        } ],
        :phpdoc => [ {
          /\*\// => [ :comment, :close ],
          
          /@\w+/ => [ :variable ],
          
          /\*/ => :comment, # awkward bugfix
          /[^@\*]+?/ => :comment,
        } ],
        :escape_bracket => [ {
          /\}/ => [ :variable, :close ],
        }, [ :variable ] ],
        :double_quote => [ {
          /"/ => [ :string, :close ],
          
          /\{(?:\$)/ => [ :variable, :escape_bracket ],
          
          /[^\\"]*(?:\\.)*/m => :string,
        }, [ :variable ] ],
        :function => [ {
          /\)/ => [ :function, :close ],
        }, [ :php ] ],
        :reserved => [ {
          /\)/ => [ :reserved, :close ],
        }, [ :php ] ],
        :goto => [ {
          /\w+/ => :identifier,
          
          /;/ => [ :punctuation, :close ],
        } ],
      }
      
      
      def php_heredoc
        puts 'hello'
        opener = matched.scan( /(<<<([a-z]+|"[a-z]+"))/i )
        p = t( :string, opener[0][0] )
        closer_regexp = Regexp.new( '\n' + opener[0][1] + '(;)?', Regexp::MULTILINE )
        string_regexp = Regexp.new( '[^\{\}\n\\\$]+?(?!' + opener[0][1] + '(;)?)' )
        
        heredoc_tokens = {
          :base => [ {
            closer_regexp => [ :string, :close ],
            
            /\\\$/ => [ :string ],
            
            /\{/ => [ :string, :heredoc_variable ],
          }, [ :basic_variable ] ]
        }
        processed_tokens = process_tokens( heredoc_tokens[:base] )
        processed_tokens[string_regexp] = :string
        
        while a = _tokenize( processed_tokens )
          a = [ a ] unless a.is_a? Array
          p << a[0]
          break if ( a.length > 1 && a[1] == :close ) || eos?
        end
        p
      end
    end
    
end
