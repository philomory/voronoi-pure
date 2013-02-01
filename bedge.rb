class BEdge
  attr_accessor :start, :end, :site, :flag
  def initialize(site,start,finish)
    @flag = true
    @site, self.start, self.end = site, start, finish
  end
  def sites
    [@site]
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
  
  def points
    [@start,@end]
  end

end