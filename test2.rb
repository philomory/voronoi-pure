# Converted to ruby from AS3 source.
# Original AS3 code by Ivan Kuckir
# AS3 Source copied from http://blog.ivank.net/voronoi-diagram-in-as3.html
# Converted to Ruby by Adam Gardner

require 'gosu'
require_relative 'voronoi'
require 'pry'
require 'fiber'
require 'opengl'


include Gl
include Glu

class VoronoiTestWin < Gosu::Window
  def initialize
    super(1000,800,false)
    @vertex_count = 100
    setup_diagram
  end
  
  def setup_diagram
    @session_done = false
    @paused = true
    @v = Voronoi.new()
    @places = Array.new(@vertex_count) { Point.new(rand(980)+10,rand(789)+10) }
    while @places.uniq! {|v| v.y } || @places.uniq! {|v| v.x }
      @places += Array.new(@vertex_count - @places.count) { Point.new(rand(980)+10,rand(789)+10) }
    end
    
    @edges = @v.get_edges(@places,1000,800)

    @factor = 1.0
  end
  
  def update
    unless @paused
      step
    end
  end
  
  def step
    lloyd_relaxation
    gather_info
  end
  
  def gather_info
    @places.each do |place|
      puts "edges: #{place.polygon.vertices.size}"
      puts "connections: #{@edges.select {|e| e.sites.include?(place)}.count}"
    end
    puts
  end
  
  def lloyd_relaxation
    relaxed_vertices = []
    @places.each do |place|
      region = place.polygon
      x, y = 0, 0
      region.vertices.each do |v|
        x += v.x
        y += v.y
      end
      x /= region.vertices.length
      y /= region.vertices.length
      relaxed_vertices << Point.new(x,y)
    end
    @v = Voronoi.new()
    @places = relaxed_vertices
    @edges = @v.get_edges(@places,1000,800)
  end
  
  def draw
    white_background
    scale(@factor, @factor,500,400) do
      #draw_polygons
      draw_points
      draw_delaunay
      draw_voronoi
      #draw_parabolas
      #draw_parabolas2
    end
    draw_cursor
  end
  
  def draw_polygons
    gl do
      glTranslatef 500, 400, 0
      glScalef @factor, @factor, @factor
      glTranslatef -500, -400, 0
      glPolygonMode(GL_FRONT_AND_BACK,GL_FILL)
      @places.each do |place|
        poly = place.polygon
        next unless poly
        glColor3f *poly.color
        glBegin(GL_POLYGON)
        poly.vertices.each do |v|
          glVertex2d(v.x,v.y)
        end
        glEnd
      end
    end
  end
  
  def draw_cursor
    c = Gosu::Color::GREEN
    x,y = mouse_x, mouse_y
    draw_quad(x-3,y-3,c,x+3,y-3,c,x+3,y+3,c,x-3,y+3,c,3)
  end
  
  def white_background
    c = Gosu::Color::WHITE
    draw_quad(0,0,c,1000,0,c,1000,800,c,0,800,c,0)
  end
  
  def draw_points
    c = Gosu::Color::BLUE
    @places.each do |p|
      s = p.flag ? 5 : 1
      x,y = p.x.to_i, p.y.to_i
      draw_quad(x-s,y-s,c,x+s,y-s,c,x+s,y+s,c,x-s,y+s,c)
    end
  end
  
  def draw_delaunay
    c1 = 0x88888888
    c2 = Gosu::Color::GREEN
    @edges.each do |edge|
      next if edge.is_a? BEdge
      c = (edge == $finished_edge || edge.flag) ? c2 : c1
      draw_line(edge.left.x,edge.left.y,c,edge.right.x,edge.right.y,c)
    end
  end
  
  def draw_voronoi
    c1 = Gosu::Color::BLACK
    c2 = Gosu::Color::RED
    @edges.each do |edge|
      c = (edge == $finished_edge || edge.flag) ? c2 : c1
      draw_line(edge.start.x,edge.start.y,c,edge.end.x,edge.end.y,c) if edge.start && edge.end
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
    when Gosu::KbR
      setup_diagram
    when Gosu::KbSpace
      start_pause_resume_reset
    when Gosu::KbNumpadSubtract
      @vertex_count -= 1
      @vertex_count = [0,@vertex_count].max
      puts "Vertext count: #{@vertex_count} (space to redraw)"
    when Gosu::KbNumpadAdd
      @vertex_count += 1
      puts "Vertext count: #{@vertex_count} (space to redraw)"
    when Gosu::KbNumpadMultiply
      @vertex_count = 20
      puts "Vertext count: #{@vertex_count} (space to redraw)"
    when Gosu::KbP
      binding.pry
    when Gosu::MsLeft
      puts "x: #{mouse_x}, y: #{mouse_y}"
    when Gosu::KbD
      dump
    when Gosu::KbL
      reload
    when Gosu::KbN
      step
    end
  end
  
  def dump
    File.open('dump.txt','w') do |f|
      Marshal.dump(@places,f)
    end
  end
  def reload
    @stepcount = 0
    @paused = true
    @session_done = false
    File.open('dump.txt') do |f|
      @places = Marshal.load(f)
    end
    @fiber = Fiber.new do
      @v.get_edges(@places,1000,800)
    end
    step
    @factor = 1.0
  end
  
  
end

w = VoronoiTestWin.new
#w.reload

w.show
