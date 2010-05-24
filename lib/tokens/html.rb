require 'cgi'

module Remus::Token
    
    class Html < Token
      def wrap
        text = CGI::escapeHTML( @text )
        return case @type
          when :plain then return text
          else
            return "<span class=\"#{@type}\">#{text}</span>"
        end
      end
    end
    
end
