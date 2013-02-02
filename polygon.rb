class Polygon
  attr_reader :vertices, :color
  def initialize(vertices)
    puts "Made a new polygon!"
    @vertices = vertices
    @color = [rand(256)/255.0,rand(256)/255.0,rand(256)/255.0]
  end

  def winding
    case signed_double_area <=> 0
    when -1 then :clockwise
    when  1 then :counterclockwise
    else         :none
    end
  end


  
  def area
    signed_double_area.abs * 0.5
  end

  def signed_double_area
    signedDoubleArea = 0
    @vertices.each_with_index do |vertex, index|
      puts @vertices
      nxt = @vertices[index+1 % @vertices.length-1]
      signedDoubleArea += vertex.x * nxt.y - nxt.x * vertex.y
    end
    signedDoubleArea
  end
end
