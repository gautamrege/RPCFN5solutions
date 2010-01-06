require "#{ARGV[0]}/grid"  # edited for unit test by ashbb

class Maze
  def initialize(maze)
    @maze = Grid.new(maze)
  end
  
  def solvable?
    steps > 0
  end
  
  def steps
    [path.length - 1, 0].max # remove start node or end node, the specs don't make this clear
  end
  
  def path
    @path ||= get_path
  end
  
  def solved
    clone = Marshal.load( Marshal.dump( @maze ) )
    path.each do |node|
      clone.node(node.x, node.y).content = "*" unless node.start? || node.end?
    end    
    clone.to_s
  end
  
  private
  
  def get_path
    @open_list = []
    @closed_list = []
    
    @maze.start_node.g = 0
    @open_list << @maze.start_node
    
    until @open_list.empty? || @closed_list.include?(@maze.end_node)
      @current_node = get_lowest_f(@open_list)
      @closed_list << @open_list.delete(@current_node)
      
      @nodes_to_test = @maze.adjecents(@current_node).select { |node| node.walkable? } - @closed_list
      
      @nodes_to_test.each do |node|
        if @open_list.include? node
          old_g = node.g
          new_g = @current_node.g + 1
          if new_g < old_g
            node.parent = @current_node
            node.g = new_g
          end
        else
          @open_list << node
          node.parent = @current_node
          node.g = node.parent.g + 1
          #node.h = (@current_node.x - @maze.end_node.x).abs + (@current_node.y - @maze.end_node.y).abs
          node.h = node.distance_from(@maze.end_node)
        end
      end
    end
    
    path = []
    if @closed_list.include?(@maze.end_node)
      node = @maze.end_node
      until node.nil?
        path << node
        node = node.parent
      end
    end
    
    path.reverse
  end
  
  def get_lowest_f(list)
    list.sort.first
  end
end