require 'lib/lexer'

module Remus
  
  # The main function.
  # Takes a string and converts it using a lexer specified by the
  # language parameter.
  def convert( string, language = :plain_text, options = {})
    class_name = Remus.classify( language )
    
    # require the language file unless the class_name is defined already
    # aka PlainText
    require "lang/#{language}" unless Remus::Lexer.const_defined?( class_name )
    
    # instantiate and return the lexer
    lexer = Remus::Lexer.const_get( class_name ).new( string, options ).convert
  end
  module_function :convert
  
  
  def convert_from_file( file, language, options = {} )
    text = IO.read(file)
    
    Remus.convert( text, language, options)
  end
  module_function :convert_from_file
  
  
  def classify( symbol )
    # convert the language symbol to a class_name
    # e.g. :plain_text => PlainText
    symbol.to_s.split('_').select {|w| w.capitalize! || w }.join('')
  end
  module_function :classify
  
  
end
