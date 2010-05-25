##
# Remus is a syntax highlighter.

class Remus
  require 'remus/lexer'

  # version
  VERSION = '0.9.0'
  
  
  ##
  # Take string and convert it based on language
  
  def self.convert( string, language = :plain_text, options = {})
    class_name = Remus.classify( language )
    
    require "remus/lang/#{language}" unless Remus::Lexer.const_defined?( class_name )
    
    lexer = Remus::Lexer.const_get( class_name ).new( string, options ).convert
  end
  
  
  ##
  # Take filename, attempt to discover language, and convert file
  
  def self.convert_from_file( filename, options = {} )
    text = IO.read(filename)

    unless language = options[:language]
      language = File.extname(filename).delete('.') || parse_shebang(text)
      case language
      when "rb"
        language = "ruby"
      end
    end
    
    Remus.convert( text, language, options)
  end
  
  
  ##
  # convert the language symbol to a class_name
  # 
  # e.g. :plain_text => PlainText
  
  def self.classify( symbol )
    symbol.to_s.split('_').select {|w| w.capitalize! || w }.join('')
  end
  
  
  ##
  # attempt to auto-discover the language of a file based on shebang line
  
  def self.parse_shebang( text )
    if text[0..1] == "#!"
      shebang = text.scan( /^#!.*$/ ) 
      if shebang.empty?
        nil
      else
        File.basename( shebang[0] ).split[-1]
      end
    else
      nil
    end
  end
  
  #module_function :convert, :convert_from_file, :classify, :parse_shebang

end
