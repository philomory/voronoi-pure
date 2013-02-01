# Converted to ruby from AS3 source.
# Original AS3 library by Ivan Kuckir
# AS3 Source downloaded from http://blog.ivank.net/voronoi-diagram-in-as3.html
# Converted to Ruby by Adam Gardner

class VEdge
  attr_accessor :start, :end
  attr_accessor :direction
  attr_accessor :left, :right
  attr_accessor :f, :g
  attr_accessor :neighbor
  attr_accessor :flag
  
  def initialize(s,a,b)
    #binding.pry if s.y.abs > 20608
    @flag = true
    @left, @right, @start = a, b, s
    @f = (b.x - a.x) / (a.y - b.y)
    @g = s.y - @f*s.x
    @direction = Point.new(b.y-a.y,-(b.x-a.x))
  end
  
  def end=(p)
    @end = p
    @flag = true
    binding.pry if p.y.abs >= 10000 && (p.y * @start.y < 0)
  end

end