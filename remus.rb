require 'lib/lexer'

module Remus
  
  # The main function.
  # Takes a string and converts it using a lexer specified by the
  # language parameter.
  def convert( string, language = :plain_text)
    class_name = Remus.classify( language )
    
    # require the language file unless the class_name is defined already
    # aka PlainText
    require "lang/#{language}" unless Remus.const_defined?( class_name )
    
    # instantiate and return the lexer
    lexer = Remus.const_get( class_name ).new( string )
  end
  module_function :convert
  
  
  def convert_from_file( file, language )
    # TODO: make this work
    # it should figure out the language automatically.
  end
  
  
  def classify( symbol )
    # convert the language symbol to a class_name
    # e.g. :plain_text => PlainText
    symbol.to_s.split('_').select {|w| w.capitalize! || w }.join('')
  end
  module_function :classify
  
  
  # An empty Lexer class, basically returns the string untouched
  # This is the default Lexer.
  class PlainText < Lexer
  
    def initialize( string )
      super string
      @tokens = {
        :base => {
          /[\s\S]*/ => [ :plain ]
        }
      }
    end
  
  end
  
  
end
