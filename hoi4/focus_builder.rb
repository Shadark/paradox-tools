class FocusBuilder
  def initialize(prefix, name, icon:, x:, y:, &block)
    @prefix = prefix
    @name = name
    @x = x
    @y = y
    set_icon icon
    @prerequisites = []
    @mutually_exclusive = []
    @reward = PropertyList[]
    instance_eval(&block)
  end

  def build
    raise "No icon for #{@name}" unless @icon
    raise "No X/Y for #{@name}" unless @x and @y
    Focus.new(@name, id_for_name(@name), x: @x, y: @y, reward: @reward, prerequisites: @prerequisites, icon: @icon, mutually_exclusive: @mutually_exclusive)
  end

  def loc(x,y)
    @x, @y = x, y
  end

  def req(*names)
    names.each do |name|
      @prerequisites << PropertyList["focus", id_for_name(name)]
    end
  end

  def mutually_exclusive(name)
    @mutually_exclusive << name
  end

  def army_xp(val)
    @reward.add! "army_experience", val
  end

  def air_xp(val)
    @reward.add! "air_experience", val
  end

  def research_bonus(name, uses: 1, bonus: nil, ahead: nil)
    raise "Must have some bonus" unless bonus or ahead

    bonus_name, categories, technologies = categories_for_research_bonus(name.to_s)
    reward = PropertyList[
      "name", "#{bonus_name}_bonus",
    ]
    reward.add! "bonus", bonus if bonus
    reward.add! "ahead_reduction", ahead if ahead
    reward.add! "uses", uses if uses
		categories.each do |c|
      reward.add! "category", c
    end
    technologies.each do |t|
      reward.add! "technology", t
    end
    @reward.add! "add_tech_bonus", reward
  end

  private

  def categories_for_research_bonus(name)
    bonus_name = name
    technologies = []
    categories = []
    case name
    when "land_doc"
      categories = ["land_doctrine"]
    when "air_doc"
      categories = ["air_doctrine"]
    when "infantry_weapons", "infantry_artillery"
      categories = ["artillery", "infantry_weapons"]
    # motorised / motorized inconsistency is in the game
    when "motorized_equipment"
      bonus_name = "motorized"
      categories = ["motorized_equipment"]
    when "motorised_infantry"
      bonus_name = "motorized"
      technologies = ["motorised_infantry"]
    when "armor"
      categories = ["armor"]
    when "special_forces"
      technologies = ["paratroopers", "paratroopers2", "marines", "marines2", "tech_mountaineers", "tech_mountaineers2"]
    when "fighter"
      technologies = %W[early_fighter	fighter1 fighter2	fighter3 heavy_fighter1	heavy_fighter2 heavy_fighter3]
    when "bomber"
      technologies = %W[strategic_bomber1 strategic_bomber2 strategic_bomber3]
      categories = %W[tactical_bomber]
    when "CAS"
      categories = %W[cas_bomber]
    when "nav_bomber"
      categories = %W[naval_bomber]
    when "jet_rocket"
      categories = %W[rocketry jet_technology]
    else
      raise "Can't infer bonus name for #{name}"
    end
    [bonus_name, categories, technologies]
  end

  def id_for_name(name)
    "#{@prefix}_#{name.downcase.gsub(" ", "_")}"
  end

  def set_icon(icon_name)
    @icon = case icon_name
    when *%W[
      small_arms
      army_motorized
      army_doctrines
      army_artillery
      build_tank
      army_artillery2
      army_tanks
      special_forces
      air_fighter
      air_bomber
      air_doctrine
      CAS
      air_naval_bomber
    ]
      "GFX_goal_generic_#{icon_name}"
    when "airforce"
      "GFX_goal_generic_build_#{icon_name}"
    when "infantry"
      "GFX_goal_generic_allies_build_#{icon_name}"
    when "rocketry"
      "GFX_focus_#{icon_name}"
    else
      raise "Unknown icon name #{icon_name}"
    end
  end
end
