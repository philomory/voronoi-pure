class Vertex < Point
  attr_accessor :edges_that_meet_here
  def initialize(*args)
    super(*args)
    @edges_that_meet_here = []
  end
end