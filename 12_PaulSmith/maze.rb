class Maze
  attr_accessor :maze, :ax, :ay, :bx, :by

  def initialize(maze)
  @maze = []
    maze.each_line do |line|
      @maze << line.chomp
      if @ax.nil?
        @ax = line.index('A')
        @ay = @maze.length - 1
      end
      if @bx.nil?
        @bx = line.index('B')
        @by = @maze.length - 1
      end
    end
    
    set_at(@ax, @ay, ' ') unless @ax == nil or @ay == nil
    set_at(@bx, @by, ' ') unless @bx == nil or @by == nil
    
    @steps=0
  end
  
  def symbol_at(x,y)
    @maze[y][x]
  end

  def set_at(x, y, symbol)
    @maze[y][x] = symbol
  end
    
  def colourize(x,y,colour = 'A')
    return true if x==bx && y==by
    if symbol_at(x,y) == ' '
      set_at(x,y,colour)
      return true if colourize(x, y-1, colour)
      return true if colourize(x-1, y, colour)
      return true if colourize(x, y+1, colour)
      return colourize(x+1, y, colour)
    else
      return false
    end
  end
  
  def solvable?
    colourize(ax, ay)
  end
  
end