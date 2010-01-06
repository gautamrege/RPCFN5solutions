class Node
  attr_reader :x, :y
  attr_accessor :parent, :g, :h, :content
  
  def initialize(content, x, y)
    @x = x
    @y = y
    @content = content
  end
  
  def walkable?
    content != "#"
  end
  
  def start?
    content == "A"
  end
  
  def end?
    content == "B"
  end
  
  def f
    g + h
  end
  
  def <=>(other)
    self.f <=> other.f
  end
  
  def distance_from(other)
    Math.sqrt((self.x - other.x) ** 2 + (self.y - other.y) ** 2)
  end
  
  def to_s
    content
  end
end