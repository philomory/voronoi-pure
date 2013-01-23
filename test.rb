# Converted to ruby from AS3 source.
# Original AS3 code by Ivan Kuckir
# AS3 Source copied from http://blog.ivank.net/voronoi-diagram-in-as3.html
# Converted to Ruby by Adam Gardner

require 'gosu'
require_relative 'voronoi'
require 'pry'

@v = Voronoi.new()
@vertices = Array.new(5) { Point.new(rand(1000),rand(800)) }
#binding.pry
@edges = @v.get_edges(@vertices,1000,800)

class VoronoiTestWin < Gosu::Window
  def initialize
    super(1000,800,false)
    
    @v = Voronoi.new()
    @vertices = Array.new(5) { Point.new(rand(1000),rand(800)) }
    #binding.pry
    @edges = @v.get_edges(@vertices,1000,800)
    @factor = 1.0
    #p @vertices
    #p @edges[0].start
    #p @edges[0].end
  end
  
  def draw
    white_background
    scale(@factor, @factor,500,400) do
      draw_points
      draw_delaunay
      draw_voronoi
    end
  end
  
  def white_background
    c = Gosu::Color::WHITE
    draw_quad(0,0,c,1000,0,c,1000,800,c,0,800,c)
  end
  
  def draw_points
    c = Gosu::Color::RED
    @vertices.each do |p|
      x,y = p.x.to_i, p.y.to_i
      draw_quad(x-1,y-1,c,x+1,y-1,c,x+1,y+1,c,x-1,y+1,c)
    end
  end
  
  def draw_delaunay
    c = 0x88888888
    @edges.each do |edge|
      draw_line(edge.left.x,edge.left.y,c,edge.right.x,edge.right.y,c)
    end
  end
  
  def draw_voronoi
    c = Gosu::Color::BLACK
    @edges.each do |edge|
      draw_line(edge.start.x,edge.start.y,c,edge.end.x,edge.end.y,c)
    end
  end
  
  def button_down(id)
    case id
    when Gosu::KbEscape
      close
    when Gosu::KbUp
      @factor *= 2
    when Gosu::KbDown
      @factor /= 2
    when Gosu::KbEnter
      @factor = 1
    end
  end
end

VoronoiTestWin.new.show
