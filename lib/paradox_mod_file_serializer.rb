class ParadoxModFileSerializer
  attr_reader :output
  def initialize
    @output = ""
    @indent = 0
  end

  def line!(str)
    @output << "  " * @indent << str << "\n"
  end

  def primitive?(val)
    case val
    when TrueClass, FalseClass, Numeric, String, Date
      true
    else
      false
    end
  end

  def serialize_primitive(val)
    case val
    when TrueClass
      "yes"
    when FalseClass
      "no"
    when Numeric
      val.to_s
    when Date
      "%d.%d.%d" % [val.year, val.month, val.day]
    when /\A[A-Za-z0-9_\.]+\z/
      val
    when /\A[A-Za-z0-9_\. ]*\z/
      # A lot more Strings are allowed, but at some point we'll need to think about escaping them
      '"' + val + '"'
    else
      # Could be String that needs escaping, or something else unusual
      require 'pry'; binding.pry
    end
  end

  def print_property_list!(node)
    raise "No idea how to print this" unless node.is_a?(PropertyList)
    node.each do |key,val|
      if val.is_a?(PropertyList)
        line! "#{key} = {"
        @indent += 2
        print_property_list! val
        @indent -= 2
        line! "}"
      elsif val.is_a?(Array)
        # Empty Array is indistinguishable from empty PropertyList
        if val.all?{|v| primitive?(v)}
          line! "#{key} = {"
          @indent += 2
          val.each do |v|
            line! serialize_primitive(v)
          end
          @indent -= 2
          line! "}"
        end
      elsif primitive?(val)
        line! "#{key} = #{serialize_primitive(val)}"
      else
        raise "Not sure how to serialize #{val.class}"
      end
    end
  end

  def self.serialize(node, orig_node)
   s = ParadoxModFileSerializer.new
   s.print_property_list!(node) # Ignore orig_node completely for now
   s.output
  end
end