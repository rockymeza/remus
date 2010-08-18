$: << File.dirname(__FILE__)

##
# Remus is a syntax highlighter.  It colors code like never before.
#
# == How to Remus?
# Oh so now you wanna jump on the bandwagon. Ok.
#
# === Command Line Remus
# you can user Remus from the command line.
# 
#   remus [options] [code]
#
# === Inside Ruby Remus
# note that all of Remus' methods are static methods so there is no
# need to instantiate Remus. This lends to simpler syntax
# 
#   Remus.convert( string, language = :plain_text, options = {} )

class Remus
  require 'remus/lexer'

  # version
  VERSION = '0.9.3'
  
  
  # Takes string and converts it based on language
  #
  # Remus.convert( 'Hello World!', :php, :token_class => :html )
  def self.convert( string, language = :plain_text, options = {})
    class_name = Remus.classify( language )
    
    require "remus/lang/#{language}" unless Remus::Lexer.const_defined?( class_name )
    
    lexer = Remus::Lexer.const_get( class_name ).new( string, options ).convert
  end
  
  
  # Takes filename, attempts to discover language, and converts file
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
  
  
  # converst the language symbol to a class_name
  # 
  # e.g. :plain_text => PlainText
  def self.classify( symbol )
    symbol.to_s.split('_').select {|w| w.capitalize! || w }.join('')
  end
  
  
  # attempts to auto-discover the language of a file based on shebang line
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
  
end
