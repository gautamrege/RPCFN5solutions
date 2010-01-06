require "#{ARGV[0]}/node"  # edited for unit test by ashbb

class Grid
  def initialize(grid)
    @grid = parse(grid)
  end
  
  def node(x, y)
    @grid[y][x]
  end
  
  def nodes
    @nodes ||= @grid.flatten
  end
  
  def walkable_nodes
    @walkable_nodes ||= nodes.select { |node| node.walkable? }
  end
  
  def width
    @grid[0].length
  end
  
  def height
    @grid.length
  end
  
  def start_node
    @start_node ||= walkable_nodes.find { |node| node.start? }
  end
  
  def end_node
    @end_node ||= walkable_nodes.find { |node| node.end? }
  end
  
  def adjecents(center)
    nodes.select do |node|
      ((center.x == node.x + 1 || center.x == node.x - 1) && center.y == node.y) ||
      ((center.y == node.y + 1 || center.y == node.y - 1) && center.x == node.x)
    end
  end
  
  def to_s
    @grid.map { |row| row.join("") }.join("\n")
  end
  
  private
  
  def parse(grid)
    rows = grid.split("\n")
    matrix = Array.new(rows.length) { Array.new(rows.first.length) }
    
    rows.each_with_index do |row, y|
      row.split("").each_with_index do |char, x|
        matrix[y][x] = Node.new(char, x, y)
      end
    end
    
    matrix
  end
end