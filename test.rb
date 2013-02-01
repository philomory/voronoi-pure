# Converted to ruby from AS3 source.
# Original AS3 code by Ivan Kuckir
# AS3 Source copied from http://blog.ivank.net/voronoi-diagram-in-as3.html
# Converted to Ruby by Adam Gardner

require 'gosu'
require_relative 'voronoi'
require 'pry'
require 'fiber'


class VoronoiTestWin < Gosu::Window
  def initialize
    super(1000,800,false)
    @vertex_count = 200
    setup_diagram
  end
  
  def setup_diagram
    @stepcount =0
    @old_edges = []
    @edges = []
    @new_edges = []
    @session_done = false
    @paused = true
    @v = Voronoi.new()
    @vertices = Array.new(@vertex_count) { Point.new(rand(980)+10,rand(789)+10) }
    while @vertices.uniq! {|v| v.y } || @vertices.uniq! {|v| v.x }
      @vertices += Array.new(@vertex_count - @vertices.count) { Point.new(rand(980)+10,rand(789)+10) }
    end
    #@vertices += [Point.new(500,350),Point.new(500,400),Point.new(500,450),Point.new(500,500)]
    
    @fiber = Fiber.new do
      @v.get_edges(@vertices,1000,800)
    end
    step
    @factor = 1.0
  end
  
  def update
    unless @paused
      step
    end
  end
  
  def step
    if @fiber.alive?
      @stepcount+=1
      @edges.each {|e| e.flag = false}
      #binding.pry if @stepcount == 18
      @edges = @fiber.resume || @edges
      
    else
      @session_done = true
    end
  end
  
  def draw
    white_background
    scale(@factor, @factor,500,400) do
      draw_points
      draw_delaunay
      draw_voronoi
      draw_beechline
      #draw_parabolas
      #draw_parabolas2
    end
    draw_cursor
  end
  
  def draw_beechline
    c = Gosu::Color::RED
    y = @v.instance_variable_get(:@ly)
    draw_line(0,y,c,1000,y,c)
  end
  
  def draw_cursor
    c = Gosu::Color::GREEN
    x,y = mouse_x, mouse_y
    draw_quad(x-1,y-1,c,x+1,y-1,c,x+1,y+1,c,x-1,y+1,c,1)
  end
  
  def white_background
    c = Gosu::Color::WHITE
    draw_quad(0,0,c,1000,0,c,1000,800,c,0,800,c)
  end
  
  def draw_points
    c = Gosu::Color::BLUE
    @vertices.each do |p|
      s = p.flag ? 5 : 1
      x,y = p.x.to_i, p.y.to_i
      draw_quad(x-s,y-s,c,x+s,y-s,c,x+s,y+s,c,x-s,y+s,c)
    end
  end
  
  def draw_parabolas2
    y = @v.instance_variable_get(:@ly)
    @v.instance_variable_get(:@parabolas).each do |par|
      draw_parabola(par.site,y)
    end
  end
    
  
  def draw_parabola(p,y)
    return unless p
    dp = 2*(p.y - y)
    a1 = 1/dp
    b1 = -2*p.x/dp
    c1 = y+dp/4 + p.x*p.x/dp
    
    c = Gosu::Color::BLACK
    -500.step(1000,5) do |i|
      j = i+5
      y1 = a1*i*i + b1*i + c1
      y2 = a1*j*j + b1*j + c1
      draw_line(i,y1,c,i+5,y2,c)
    end
  end
  
  def draw_parabolas
    p = @v.instance_variable_get(:@root)
    y = @v.instance_variable_get(:@ly)
    draw_parabola_with_children(p,y)
  end
  
  def draw_parabola_with_children(p,y)
    draw_parabola(p.site,y)# if p.cEvent
    unless p.isLeaf
      draw_parabola_with_children(p.right,y)
      draw_parabola_with_children(p.left,y)
    end
  end
  
  def draw_delaunay
    c1 = 0x88888888
    c2 = Gosu::Color::GREEN
    @edges.each do |edge|
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
  
  def start_pause_resume_reset
    if @session_done
      @session_done = false
      @paused = true
      reset_diagram
    elsif @paused
      @paused = false
    else
      @paused = true
    end
  end
  
  def reset_diagram
    @stepcount =0
    @v = Voronoi.new
    @fiber = Fiber.new do
      @v.get_edges(@vertices,1000,800)
    end
    step
  end
  
  def dump
    File.open('dump.txt','w') do |f|
      Marshal.dump(@vertices,f)
    end
  end
  def reload
    @stepcount = 0
    @paused = true
    @session_done = false
    File.open('dump.txt') do |f|
      @vertices = Marshal.load(f)
    end
    @fiber = Fiber.new do
      @v.get_edges(@vertices,1000,800)
    end
    step
    @factor = 1.0
  end
  
  
end

w = VoronoiTestWin.new
#w.reload

w.show
