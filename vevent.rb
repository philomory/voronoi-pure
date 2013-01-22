# Converted to ruby from AS3 source.
# Original AS3 library by Ivan Kuckir
# AS3 Source downloaded from http://blog.ivank.net/voronoi-diagram-in-as3.html
# Converted to Ruby by Adam Gardner

class VEvent
  include Comparable
  
  attr_accessor :point, :pe
  attr_accessor :y, :key
  attr_accessor :arch
  attr_accessor :value
  
  def initialize(p,pe)
    @point, @pe = p, pe
    @y = p.y
    @key = rand(100000000000)
  end

  def <=>(other)
    y <=> other.y
  end
  
end