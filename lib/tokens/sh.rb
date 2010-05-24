module Remus::Token
    
    class Sh < Token
      def wrap
        send( @type, @text )
      end
      
      def colorize(text, color_code)
        "#{color_code}#{text}\e[0m"
      end

      # plain
      def plain(text); text; end
      
      # keyword
      def keyword(text); colorize(text, "\e[1m\e[33m"); end
      
      # reserved
      def reserved(text); colorize(text, "\e[33m"); end
      
      # comment
      def comment(text); colorize(text, "\e[1m\e[36m"); end
      
      # string
      def string(text); colorize(text, "\e[32m"); end
      
      # number
      def number(text); colorize(text, "\e[34m"); end
      
      # function
      def function(text); colorize(text, "\e[1m\e[35m"); end
      
      # property
      def property(text); colorize(text, "\e[35m"); end
      
      # operator
      def operator(text); colorize(text, "\e[1m\e[30m"); end
      
      # identifier
      def identifier(text); colorize(text, "\e[1m\e[32m"); end
      
      # variable
      def variable(text); colorize(text, "\e[36m"); end
      
      # punctuation
      def punctuation(text); colorize(text, "\e[35m"); end
    end
    
end
