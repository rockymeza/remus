class Regina
  VERSION = '0.0.1'

  SPECIAL_NAMES = { 
    :dry_run => :n }

  META = %w(title description version copyright)
  METAS = %w(author usage)

  attr_reader :options
  attr_reader :subcommand
  attr_reader :argv
  attr_reader :flags

  def self.next_flag
    if ARGV[0] && ARGV[0][0] == '-'
      return ARGV.shift
    end
  end

  def self.next_arg
    if ARGV[0] && ARGV[0][0] != '-'
      return ARGV.shift
    end
  end

  def self.error( message )
    puts "\e[1m\e[31mError:\e[0m #{message}"
    exit
  end

  def self.warning( message )
    puts "\e[1m\e[33mWarning:\e[0m #{message}"
  end

  def initialize( *a, &b )
    @meta = {}
    META.each do |meta|
      add_meta meta, nil
    end
    METAS.each do |meta|
      add_meta meta, [] # set it to an empty array
    end

    @options = {}
    @commands = {}
    @flags = FlagContainer.new
    @argv = []
    @subcommand = nil

    add_option :special, :help, 'Display this help message and exit'
    add_option :special, :version, 'Display the version'

    @self = eval 'self', b.binding
    self.instance_eval &b

    METAS.each do |meta|
      @meta[meta.to_sym].flatten!
    end

    check_commands if ! @commands.empty?
    parse_flags until ARGV.empty?
  end

  def main
    if @subcommand
      @self.send @subcommand
    else
      display_help
    end
  end

  # provides hash access for options
  def []( key )
    @options[key]
  end

  def []=( key, value )
    @options[key] = value
  end

  def add_meta( key, value )
    @meta[key.to_sym] = value
  end

  def add_metas( key, value )
    @meta[key.to_sym] << value
  end

  def check_commands
    if @commands.has_key?(ARGV[0])
      @subcommand = Regina.next_arg
    end
  end

  def parse_flags
    if argv = Regina.next_flag
      if %w(-h --help).include?( argv )
        display_help
      elsif %w(-v --version).include?( argv )
        display_version
      elsif arg = argv.match( /^--([a-z0-9]+)(?:=(.*?))?$/i ) # two dashes
        return set_option arg if @flags[ arg[1] ]
      elsif arg = argv.match( /^-([a-z0-9])(?:=(.*?))?$/i ) # single dash
        return set_option arg if @flags[ arg[1] ]
      elsif arg = argv.match( /^-([a-z0-9]+$)/i )
        options = []
        arg[1].each_char do |c|
          if @flags[ c ]
            options << c
          else
            self.warning "What do you want me to do with '#{arg}'?"
            return
          end
        end
        if options
          options.each { |c| set_option c}
          return
        end
      end
    else
      return @argv << Regina.next_arg
    end
    self.warning "What do you want me to do with '#{arg}'?"
  end

  def set_option( arg )
    if arg.is_a? MatchData
      flag_name, value = arg[1], arg[2]
    elsif arg.is_a? Array
      flag_name, value = arg[0], arg[1]
    else
      flag_name = arg
    end

    flag = @flags[ flag_name ]
    @options[ flag.options[:long_name] ] = flag.set( value )
  end

  def add_option( type, long_name, description, options = {})
    options[:long_name] = long_name
    options[:description] = description
    options[:short_name] ||= shorten_name( long_name )

    @flags.add( Flag.new( type, options ) )

    # this is sort of odd
    if options[:default]
      @options[ long_name ] = @flags[ long_name ].set_default( options[:default] )
    end
  end

  def command( long_name, description, options = {}, &block )
    options[:description] = description
    options[:block] = block

    @commands[ long_name ] = options
  end
  alias :sub :command

  def shorten_name(long_name)
    short_name = SPECIAL_NAMES[ long_name ] ||
                 @flags.uniq?( long_name[0] ) ||
                 @flags.uniq?( long_name[0].capitalize )

    short_name || self.error( 'Could not determine short_name for option: #{long_name}.  Please specify one.' )
  end

  def display_help
    message = Message.new
    message << @meta[:title]
    message << @meta[:description] if @meta[:description]
    message << ''

    if @meta[:usage]
      message << 'Usage:'
      @meta[:usage].each do |usage|
        message << "\t" + usage
      end
    end

    if ! @flags.empty?
      message << 'Options:'
      @flags.each do |long_name, flag|
        message << format( "-#{flag.options[:short_name]}, --#{flag.options[:long_name]}", flag.options[:description] )
      end
    end

    if ! @commands.empty?
      message << 'Commands:'
      @commands.each do |name, command|
        message << format( name, command[:description] )
      end
    end
    
    puts message
    exit
  end

  def display_version
    message = Message.new
    message << "#{@meta[:title]} v#{@meta[:version]} (C) #{@meta[:copyright]} #{@meta[:author].join(', ')}"

    puts message
    exit
  end
  
  def format(left, right)
    padding = ' ' * (31 - left.length)
    return "\t" +
    left +
    padding +
    right
  end

  def method_missing(method, *a, &b) # meta programming for DRYness
    if Flag::TYPES.include?(method.to_s) # option adding
      add_option method, *a
    elsif META.include?(method.to_s) # singular meta data adding
      add_meta method, a[0]
    elsif METAS.include?(method.to_s) # plural meta data adding
      add_metas method, a[0]
    else
      super method, *a, &b
    end
  end

  class Message < Array
    def to_s
      self.join("\n")
    end
  end
  class FlagContainer < Hash
    def initialize
      @short_names = {}
    end

    def add( flag )
      self[flag.options[:long_name]] = flag
      @short_names[ flag.options[:short_name] ] = flag.options[:long_name]
    end

    def [] ( key )
      if key.length == 1 && @short_names.has_key?( key )
        super @short_names[ key ]
      else
        super key
      end
    end

    def uniq?( value )
      return false if self.has_key? value
      value
    end
  end
  class Flag
    TYPES = %w(string int file bool)

    attr_reader :type
    attr_reader :options

    def initialize( type, options = {})
      @type = type
      @options = options
    end

    def set( value )
      @value = case @type
        when :string, :int
          value || Regina.next_arg || @options[:default]
        when :bool
          true
      end
      validate_type

      return @value
    end

    def set_default( value )
      @options[:default] = value
      set( value )
    end

    def validate_type
      if @type == :bool
        true
      else
        case @type
        when :string
          if ! @value.is_a?(String)
            self.error "'--#{@options[:long_name]}' requires a string value"
          end
        when :int
          if ! @value =~ /^[0-9]+$/
            self.error "#{@options[:long_name]} requires an integer value"
          end
        when :file
          if ! File.exists?(@value)
            self.error "#{@options[:long_name]} requires a file"
          end
        end
      end
    end

    def format
      padding = ' '*(25 - @options[:long_name].length)
      "\t-#{options[:short_name]}, --#{@options[:long_name] + padding + @options[:description]}"
    end
  end
end

module Kernel
end
