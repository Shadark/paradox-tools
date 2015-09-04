# Not sure what to name this class...
class MapManager
  attr_reader :province_id_to_title, :title_to_province_id, :culture_in_county
  attr_reader :title_capitals, :counties_in_duchy, :landed_titles_lookup

  def initialize(builder)
    @builder = builder
    @province_id_to_title = {}
    @title_to_province_id = {}
    @culture_in_county    = {}
    @landed_titles_lookup = {}
    @title_capitals       = {}
    @counties_in_duchy    = {}

    @builder.glob("history/provinces/*.txt").each do |path|
      id = path.basename.to_s.to_i
      node = @builder.parse(path)
      title = node["title"]
      @province_id_to_title[id] = title
      @title_to_province_id[title] = id
      cultures =  [node["culture"], *node.list.map{|_,v| v["culture"] if v.is_a?(PropertyList)}].compact
      @culture_in_county[title] = cultures.last
    end

    deep_search_direct(landed_titles) do |node, path|
      if path[-1] =~ /\A[ekdcb]_/
        @landed_titles_lookup[path[-1]] = path.reverse
      end
      if path[-1] == "capital"
        title = path[-2]
        @title_capitals[title] = province_id_to_title[node]
      end
      if path[-1] =~ /\Ac_/
        duchy, county = path[-2], path[-1]
        (@counties_in_duchy[duchy] ||= []) << county
      end
    end
  end

  def cultures_in_duchy(duchy)
    counties_in_duchy[duchy].map{|c| culture_in_county[c]}
  end

private

  def landed_titles
    @landed_titles ||= @builder.parse("common/landed_titles/landed_titles.txt")
  end

  def deep_search_direct(node, path=[], &blk)
    node.each do |key, val|
      subpath =  [*path, key]
      if val.is_a?(PropertyList)
        deep_search_direct(val, subpath, &blk)
      end
      yield(val, subpath)
    end
  end
end
