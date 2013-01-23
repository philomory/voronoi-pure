class Point
  attr_accessor :x, :y
  def initialize(x,y)
    @x, @y = x.to_f, y.to_f
    raise ArgumentError.new if (@x.nan? || @y.nan?)
  end
  def distance_to(other)
    Math.sqrt((self.x - other.x)**2 + (self.y - other.y)**2)
  end
end