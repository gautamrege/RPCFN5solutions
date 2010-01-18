class Maze
  WALL = '#'
  FREE = ' '
  
  def initialize(maze)
    @wip_maze = maze.split("\n").collect { |row| row.split('') }
    solve
  end
  
  def solvable?
    steps > 0
  end
  
  attr_writer :steps
  def steps
    @steps ||= calc_steps
  end

  def calc_steps
    spaces = @wip_maze.flatten.inject(0) { |s,c| s += (c == FREE) ? 1 : 0 }
    spaces > 0 ? spaces + 1 : 0
  end
 
  def solve
    @wip_maze.each_index do |r|
      @wip_maze[r].each_index do |c|
        fill_from_deadend?(r,c)
      end
    end
  end
   
  def fill_from_deadend?(r,c)
    return false unless @wip_maze[r][c] == FREE
    n = (r == 0) || (@wip_maze[r-1][c] == WALL) ? 1 : 0
    s = (r == @wip_maze.size-1) || (@wip_maze[r+1][c] == WALL) ? 1 : 0
    e = (c == 0) || (@wip_maze[r][c-1] == WALL) ? 1 : 0
    w = (c == @wip_maze[r].size-1) || (@wip_maze[r][c+1] == WALL) ? 1 : 0
    if (n+s+e+w)>2
      @wip_maze[r][c] = WALL
      fill_from_deadend?(r-1,c) if n==0
      fill_from_deadend?(r+1,c) if s==0
      fill_from_deadend?(r,c-1) if e==0
      fill_from_deadend?(r,c+1) if w==0
    end
  end
  
end