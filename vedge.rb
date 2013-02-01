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
    @left, @right, self.start = a, b, s
    @f = (b.x - a.x) / (a.y - b.y)
    @g = s.y - @f*s.x
    @direction = Point.new(b.y-a.y,-(b.x-a.x))
  end
  
  def end=(p)
    if @end
      @end.edges_that_meet_here.delete(self)
    end
    @end = p
    @end.edges_that_meet_here.push(self)
    @flag = true
    #binding.pry #if p.y.abs >= 10000 && (p.y * @start.y < 0)
  end
  
  def start=(p)
    if @start
      @start.edges_that_meet_here.delete(self)
    end
    @start = p
    @start.edges_that_meet_here.push(self)
    @flag = true
  end

  def sites
    [@left,@right]
  end
  
  def points
    [@start, @end]
  end

end