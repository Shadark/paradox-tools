require "pp"

class PropertyList
  def initialize
    @list = []
  end

  def add!(key, val)
    @list << [key, val]
  end

  def [](key)
    @list.each{|k,v| return v if key == k}
    return nil
  end

  def each(&blk)
    @list.each(&blk)
  end

  def inspect
    @list.inspect
  end
end

class ParadoxModFile
  attr_reader :path
  def initialize(path)
    @path = path
    @data = File.read(path)
    tokenize!
  end

  def each_token
    data = @data.dup
    data.gsub!(/#.*\n/, "\n")
    until data.empty?
      if data.sub!(/\A\s+/, "")
        # next
      elsif data.sub!(/\A(-?\d+\.\d+)/, "")
        yield $1.to_i
      elsif data.sub!(/\A(-?\d+)/, "")
        yield $1.to_i
      elsif data.sub!(/\A([=\{\}])/, "")
        yield({"{" => :open, "}" => :close, "=" => :eq}[$1])
      elsif data.sub!(/\A([a-zA-Z][a-zA-Z0-9_]*)/, "")
        if $1 == "yes"
          yield true
        elsif $1 == "no"
          yield false
        else
          yield $1
        end
      else
        raise "Parse error in #{path}: #{data[0, 100]}..."
      end
    end
  end

  def parse_error!
    raise "Parse error: #{@tokens.inspect}"
  end

  def tokenize!
    unless @tokens
      @tokens = []
      each_token{|tok| @tokens << tok}
    end
  end

  def parse_primitive
    if @tokens[0].is_a?(Integer) or @tokens[0].is_a?(Float) or
       @tokens[0].is_a?(String) or @tokens[0] == true or @tokens[0] == false
      @tokens.shift
    else
      parse_error!
    end
  end

  def parse_close
    parse_error! unless @tokens[0] == :close
    @tokens.shift
  end

  def parse_val
    if @tokens[0] == :open
      @tokens.shift
      if @tokens[1] == :eq
        parse_obj.tap{
          parse_close
        }
      elsif @tokens[1] == :close
        parse_primitive.tap{
          parse_close
        }
      else
        parse_error!
      end
    else
      parse_primitive
    end
  end

  def parse_attr
    if @tokens[0].is_a?(String) and @tokens[1] == :eq
      key = @tokens.shift
      @tokens.shift
      val = parse_val
      [key, val]
    else
      nil
    end
  end

  def parse_obj
    rv = PropertyList.new
    while true
      a = parse_attr
      break unless a
      rv.add!(*a)
    end
    rv
  end

  def parse_file
    rv = parse_obj
    raise "Parse error" unless @tokens.empty?
    rv
  end
end
