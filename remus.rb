require 'lib/lexer'

module Remus
  
  # The main function.
  # Takes a string and converts it using a lexer specified by the
  # language parameter.
  def convert( string, language = :plain_text, options = { :token_class => :html })
    class_name = Remus.classify( language )
    
    # require the language file unless the class_name is defined already
    # aka PlainText
    require "lang/#{language}" unless Remus::Lexer.const_defined?( class_name )
    
    # instantiate and return the lexer
    lexer = Remus::Lexer.const_get( class_name ).new( string, options ).convert
  end
  module_function :convert
  
  
  def convert_from_file( filename, lang = :plain_text, options = {} )
    text = IO.read(filename)

    if lang == :plain_text
      language = File.extname(filename).delete('.') || parse_shebang(text) || lang
      case language
      when "rb"
        language = "ruby"
      end
    else
      language = lang
    end
    
    Remus.convert( text, language, options)
  end
  module_function :convert_from_file
  
  
  def classify( symbol )
    # convert the language symbol to a class_name
    # e.g. :plain_text => PlainText
    symbol.to_s.split('_').select {|w| w.capitalize! || w }.join('')
  end
  module_function :classify
  
  private

  def parse_shebang(text)
    if text[0..1] == "#!"
      shebang = text.scan(/^#!.*$/)
      if shebang.empty?
        nil
      else
        File.basename(shebang[0]).split[-1]
      end
    else
      nil
    end
  end

end
