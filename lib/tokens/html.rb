module Remus
  module Token
    
    class Html < Token
      def wrap
        return case @type
          when :plain then return @text
          else
            return "<span class=\"#{@type}\">#{@text}</span>"
        end
      end
    end
    
  end
end
