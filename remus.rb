require 'lib/lexer'

module Remus
  
  # The main function.
  # Takes a string and converts it using a lexer specified by the
  # language parameter.
  def convert( string, language = :plain_text)
  
    # convert the language symbol to a class_name
    # e.g. :plain_text => PlainText
    class_name = language.to_s.split('_').select {|w| w.capitalize! || w }.join('')
    
    # require the language file unless the class_name is defined already
    # aka PlainText
    require "lang/#{language}" unless Remus.const_defined?(class_name) 
    
    # call convert on the lexer.
    Remus.const_get(class_name).send('convert', string)
    
  end
  module_function :convert
  
  
  def convertFromFile( file, language )
    # TODO: make this work
    # it should figure out the language automatically.
  end
  
  
  # An empty Lexer class, basically returns the string untouched
  # This is the default Lexer.
  class PlainText < Lexer
  end
  
  
end
