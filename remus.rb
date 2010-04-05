require 'lib/lexer'

module Remus
  
  class PlainText < Lexer
    
    
  end
  
  def convert( string, language = :plain_text)
    class_name = language.to_s.split('_').select {|w| w.capitalize! || w }.join('')

    require 'lang/#{language}' unless Remus.const_defined?(class_name)
    
    Remus.const_get(class_name).send('convert', string)
  end
  module_function :convert
  
  
end
