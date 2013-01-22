Point = Struct.new(:x,:y) do
  def distance_to(other)
    Math.sqrt((self.x - other.x)**2 + (self.y - other.y)**2)
  end
end