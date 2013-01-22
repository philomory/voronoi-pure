# Converted to ruby from AS3 source.
# Original AS3 library by Ivan Kuckir
# AS3 Source downloaded from http://blog.ivank.net/voronoi-diagram-in-as3.html
# Converted to Ruby by Adam Gardner

class VParabola
  attr_accessor :site, :cEvent
  attr_accessor :parent, :isLeaf
  attr_accessor :edge
  attr_reader :left, :right
  
  def initialize(s=nil)
    @site = s
    @isLeaf = !(site.nil?)
  end
  
  def left=(p)
    @left = p
    p.parent = self
  end
  
  def right=(p)
    @right = p
    p.parent = self
  end
end