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
  
  def initialize(s,a,b)
    @left, @right, @start = a, b, s
    @f = (b.x - a.x) / (a.y - b.y)
    @g = s.y - @f*s.x
    @direction = Point.new(b.y-a.y,-(b.x-a.x))
  end
  
  def end=(p)
    @end = p
    puts "(#{@start.x},#{@start.y}) -> (#{@end.x},#{@end.y}): #{self.inspect}" if (@start.x < 0 && @end.x <0) || (@start.y < 0 && @end.y < 0) 
  end
  
end