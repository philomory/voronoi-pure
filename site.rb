class Site < Point
  attr_accessor :polygon
  attr_accessor :connections
  
  def initialize(*args)
    super(*args)
    @connections = []
  end
  
  def connected_sites
    @connections.map do |edge|
      edge.left == self ? edge.right : edge.left
    end
  end
  
end