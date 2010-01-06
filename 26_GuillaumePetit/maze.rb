class Maze
  
  # Constants used for the search and setup
  NOTHING = 0
  WALL    = 1
  A       = 2
  B       = 3
  WALK    = 4
  
  def initialize(maze)
    @maze = Array.new
    
    # a little bit of parsing !
    splitted_maze = maze.split("\n")
    splitted_maze.each_index do |y|
      array_line = Array.new
      x = 0
      splitted_maze[y].each_char do |char|
        case char
        when "#"
          array_line << WALL
        when "A"
          array_line << A
          @start = { :x => x, :y => y } 
        when "B"
          array_line << B
        else
          array_line << NOTHING
        end
        x += 1
      end
      @maze << array_line
    end
    
    # let's start the engine !!!
    # first, we change the starting point, from A to Nothing
    # for simplification purpose
    @maze[@start[:y]][@start[:x]] = NOTHING
   
    # starting (and shortest) depth
    @depth = 0
    
    # will try every possible path, and remember the shortest one
    find_path(@start[:x], @start[:y], @depth)
    
    # fixing our starting point modification thing back
    # for printing purpose only
    @maze[@start[:y]][@start[:x]] = A    
  end
  
  def steps
    @depth
  end
  
  def solvable?
    @depth > 0
  end
  
  # print the initial maze setup
  def print_maze
    pm @maze
  end
  
  # print the maze with the solution path in dot
  def print_solution
    if solvable?
      p "This maze can be solved in #{steps} steps"
      pm @shortest_path
    else
      p "No path found for this maze"
    end
  end
  
  private
  
  # print a maze
  def pm(maze)
    maze.each do |array_line|
      line = array_line.join
      line.gsub!(/0/, " ")
      line.gsub!(/1/, "#")
      line.gsub!(/2/, "A")
      line.gsub!(/3/, "B")
      line.gsub!(/4/, ".")
      p line
    end
  end
  
  def find_path(x, y, depth)
    if @maze[y][x] == B # found the B
      # did we find a shorter path ? (or the first one)
      if depth < @depth || @depth == 0
        # yep ! so let's save the steps
        @depth = depth 
        
        # then we make a snapshot of the current path
        @shortest_path = Marshal.load( Marshal.dump(@maze) )
        
        # fixing our starting point modification thing back
        # for printing purpose only
        @shortest_path[@start[:y]][@start[:x]] = A
      end
      
      # we stop the process for this node search
      # but it will continu to find another path, hopefully shorter !
      return
    end
    
    return if @maze[y][x] > 0 # this place is not "walkable"
    
    # let's mark this case
    @maze[y][x] = WALK
    
    # let's try the 4 direction in recursion
    find_path(x, y-1, depth+1) if y > 0                 # up first, only if possible
    find_path(x+1, y, depth+1) if x+1 < @maze[y].size   # right now, only if possible
    find_path(x, y+1, depth+1) if y+1 < @maze.size      # then down, only if possible
    find_path(x-1, y, depth+1) if x > 0                 # and left to finish, only if possible
    
    # we clean our path, since we are going back
    @maze[y][x] = NOTHING
  end
  
end
