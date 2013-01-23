# Converted to ruby from AS3 source.
# Original AS3 library by Ivan Kuckir
# AS3 Source downloaded from http://blog.ivank.net/voronoi-diagram-in-as3.html
# Converted to Ruby by Adam Gardner

require_relative 'point'
require_relative 'vedge'
require_relative 'vevent'
require_relative 'vparabola'
require_relative 'vqueue'

class Voronoi
  def initialize
    @queue = VQueue.new
  end
  
  def get_edges(places,width,height)
    @root = nil
    @places = places
    @edges = []
    @width, @height = width, height
    
    @queue.clear
    @places.each do |place|
      ev = VEvent.new(place,true)
      @queue.enqueue ev
    end
    
    @lasty = 1.0/0 # INFINITY
    num = 0
    
    until @queue.empty?
      e = @queue.dequeue
      @ly = e.point.y
      if e.pe
        insert_parabola(e.point)
      else
        remove_parabola(e)
      end
      
      if e.y > @lasty
        #Useless comment!
      end
      
      @lasty = e.y
    end
    
    finish_edge(@root)
    @edges.each do |edge|
      edge.start = edge.neighbor.end if edge.neighbor
    end
    
    @edges
  end
  
  def insert_parabola(p)
    unless @root
      @root = VParabola.new(p)
      @fp = p
      return
    end
    
    if @root.isLeaf && @root.site.y - p.y < 1
      @root.isLeaf = false
      @root.left = VParabola.new(@fp)
      @root.right = VParabola.new(p)
      s = Point.new((p.x+@fp.x)/2, @height)
      
      if p.x>@fp.x
        @root.edge = VEdge.new(s,@fp,p)
      else
        @root.edge = VEdge.new(s,p,@fp)
      end
      
      @edges.push(@root.edge)
      return
    end
    
    par = get_parabola_by_x(p.x)
    if par.cEvent
      @queue.remove(par.cEvent)
      par.cEvent = nil
    end
    
    start = Point.new(p.x,get_y(par.site,p.x))
    
    el = VEdge.new(start,par.site,p)
    er = VEdge.new(start,p,par.site)
    
    el.neighbor = er
    @edges.push el
    
    par.edge = er
    par.isLeaf = false
    
    p0 = VParabola.new(par.site)
    p1 = VParabola.new(p)
    p2 = VParabola.new(par.site)
    
    par.right = p2
    par.left = VParabola.new
    par.left.edge = el
    
    par.left.left = p0
    par.left.right = p1
    
    check_circle(p0)
    check_circle(p2)
  end
  
  def remove_parabola(e)
    p1 = e.arch
    
    xl = get_left_parent(p1)
    xr = get_right_parent(p1)
    
    p0 = get_left_child(xl)
    p2 = get_right_child(xr)
    
    if p0.cEvent
      @queue.remove(p0.cEvent)
      p0.cEvent = nil
    end
    if p2.cEvent
      @queue.remove(p2.cEvent)
      p2.cEvent = nil
    end
    
    p = Point.new(e.point.x,get_y(p1.site,e.point.x))
    
    @lasty = e.point.y
    
    xl.edge.end = p
    xr.edge.end = p
    
    par = p1
    until par == @root
      par = par.parent
      higher = xl if par == xl
      higher = xr if par == xr
    end
    
    higher.edge = VEdge.new(p, p0.site, p2.site)
    
    @edges.push(higher.edge)
    
    gparent = p1.parent.parent
    if p1.parent.left == p1
      if gparent.left == p1.parent
        gparent.left = p1.parent.right
      else
        gparent.right = p1.parent.right
      end
    else
      if gparent.left == p1.parent
        gparent.left = p1.parent.left
      else
        gparent.right = p1.parent.left
      end
    end
    
    check_circle(p0)
    check_circle(p2)
  end
  
  def finish_edge(n)
    mx = if n.edge.direction.x > 0
      [@width,n.edge.start.x + 10].max
    else
      [0,n.edge.start.x - 10].min
    end
    
    n.edge.end = Point.new(mx,n.edge.f*mx + n.edge.g)
    
    finish_edge(n.left) unless n.left.isLeaf
    finish_edge(n.right) unless n.right.isLeaf
  end
  
  def get_x_of_edge(par,y)
    left = get_left_child(par)
    right = get_right_child(par)
    
    p = left.site
    r = right.site
    
    dp = 2.0*(p.y - y)
    a1 = 1.0/dp
    b1 = -2.0*p.x/dp
    c1 = y + dp/4.0 + p.x**2 / dp
    
    dp = 2.0*(r.y - y)
    a2 = 1.0/dp
    b2 = -2.0*r.x/dp
    c2 = y+dp/4.0 +r.x**2.0 / dp
    
    a = a1 - a2
    b = b1 - b2
    c = c1 - c2
    
    disc = b**2 - 4*a*c
    x1 = (-b + Math.sqrt(disc)) / (2 * a)
    x2 = (-b - Math.sqrt(disc)) / (2 * a)
    
    ry = if p.y < r.y
      [x1,x2].max
    else
      [x1,x2].min
    end
    
    ry
  end
  
  def get_parabola_by_x(xx)
    par = @root
    x = 0.0
    
    until par.isLeaf
      x = get_x_of_edge(par, @ly)
      if x>xx
        par = par.left
      else
        par = par.right
      end
    end
    par
  end
  
  def get_y(p,x)
    dp = 2.0*(p.y - @ly)
    b1 = -2.0*p.x/dp
    c1 = @ly+dp/4.0 + p.x**2 / dp
    return x*x/dp + b1*x + c1
  end
  
  def check_circle(b)
    lp = get_left_parent(b)
    rp = get_right_parent(b)
    
    a = get_left_child(lp)
    c = get_right_child(rp)
    
    return if (a.nil? || c.nil? || a.site == c.site)
    
    s = get_edge_intersection(lp.edge,rp.edge)
    return if s.nil?
    
    d = a.site.distance_to(s)
    return if s.y - d >= @ly
    
    e = VEvent.new(Point.new(s.x,s.y-d),false)
    
    b.cEvent = e
    e.arch = b
    @queue.enqueue(e)
  end
  
  def get_edge_intersection(a,b)
    x = (b.g - a.g) / (a.f - b.f)
    y = a.f * x + a.g
    
    return nil if x.abs + y.abs > 20*@width
    return nil if a.direction.x.abs < 0.01 && b.direction.x.abs < 0.01
    return nil if (x - a.start.x) / a.direction.x < 0
    return nil if (y - a.start.y) / a.direction.y < 0
    return nil if (x - b.start.x) / b.direction.x < 0
    return nil if (y - b.start.y) / b.direction.y < 0
    
    Point.new(x,y)
  end
  
  def get_left(n)
    get_left_child(get_left_parent(n))
  end
  
  def get_right(n)
    get_right_child(get_right_parent(n))
  end
  
  def get_left_parent(n)
    par = n.parent
    pLast = n
    while par.left == pLast
      return nil unless par.parent
      pLast = par
      par = par.parent
    end
    par
  end
  
  def get_right_parent(n)
    par = n.parent
    pLast = n
    while par.right == pLast
      return nil unless par.parent
      pLast = par
      par = par.parent
    end
    par
  end
  
  def get_left_child(n)
    return nil unless n
    par = n.left
    par = par.right until par.isLeaf
    par
  end
  
  def get_right_child(n)
    return nil unless n
    par = n.right
    par = par.left until par.isLeaf
    par
  end
  
end