# Constans defining maze dimensions
ROWS=13
COLS=37

class Maze
  attr_reader :maze, :a, :b
  # Remove end of line characters
  # Verify we have a valid maze
  # What are our A & B coordinates?
  def initialize(maze)
    @maze = maze.gsub(/[\n\r]/,'')
    raise "Maze must have #{COLS} columns and #{ROWS} rows" if @maze.size != COLS*ROWS
    @a = position_to_coordinates(@maze.index('A'))
    @b = position_to_coordinates(@maze.index('B'))
  end
 
  def solvable?
    build_space(*@a)
    return true if @space.include?(@b)
    false
  end
 
  def steps
    return 0 unless solvable?
    @distances={@a=>0}
    calculate_cost(@a)
    @distances[@b]
  end
 
  private
  # calculate distance for node's neighbourhouds
  def calculate_cost(node)
    cost=@distances[node]+1
    neighbours(*node).each do |n|
      next unless @space.include?(n)
      next if @distances[n] and @distances[n] < cost
      @distances[n]=cost
      calculate_cost(n)
    end
  end
 
  # build space for (x,y) - all possible fields we can move
  def build_space(x,y)
    @space = @space || []
    neighbours(x,y).each do |s|
      next if @space.include? s
      @space << s
      build_space(*s)
    end
    @space
  end
 
  # what cells can we move to from (x,y)
  def neighbours(x,y)
    results=[]
    results << [x+1,y] if x<COLS and movable?(x+1,y)
    results << [x-1,y] if x>1 and movable?(x-1,y)
    results << [x,y-1] if y>1 and movable?(x,y-1)
    results << [x,y+1] if y<ROWS and movable?(x,y+1)
    results
  end
 
  # transition of index to (x,y) coordinates
  def position_to_coordinates(pos)
    x = pos % COLS
    y = (pos-x)/COLS
    x+=1
    y+=1
    [x,y]
  end
 
  # returns what is in the maze on (x,y)
  def cell(x,y)
    @maze[(COLS*(y-1)+x)-1].chr
  end
 
  # is (x,y) something we can move to?
  def movable?(x,y)
    [' ','A','B'].include? cell(x,y)
  end
end 
