# Converted to ruby from AS3 source.
# Original AS3 library by Ivan Kuckir
# AS3 Source downloaded from http://blog.ivank.net/voronoi-diagram-in-as3.html
# Converted to Ruby by Adam Gardner

class VQueue
  def initialize
    @q = []
  end
  
  def enqueue(event)
    @q.push event
  end
  
  def dequeue
    @q.sort!
    @q.pop
  end
  
  def remove(event)
    @q.delete(event)
  end
  
  def empty?
    @q.empty?
  end
  
  def clear
    @q.clear
  end
    
end