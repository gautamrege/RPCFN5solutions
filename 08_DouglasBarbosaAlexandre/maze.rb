class Maze

  START     = "A"
  GOAL      = "B"
  NAVIGABLE = " "
  MARKED    = "+"
  UNMARKED  = "x"

  def initialize(maze)
    @maze = [] 
    @steps = 0
    to_a(maze)
  end

  def to_a(maze)
    maze.each_line { |line| @maze << line.chomp.split(//) }
  end

  def find_start_point
    @maze.size.times do |@row|
      @column = (0..@maze[@row].size).detect { |i| @maze[@row][i] == START }
      break if @column
    end
  end
 
  def outside_maze?(x, y)
    x > @maze.size || y > @maze[0].size
  end

  def is_goal?(x, y)
    @maze[x][y] == GOAL
  end

  def not_open?(x, y)
    @maze[x][y] != NAVIGABLE && @maze[x][y] != START
  end

  def mark_as_part_of_solution_path(x, y)
    @maze[x][y] = MARKED
    @steps += 1
  end

  def unmark_as_part_of_solution_path(x, y)
    @maze[x][y] = UNMARKED
    @steps -= 1
  end

  def find_path(x, y)
    return false if outside_maze?(x, y)
    return true if is_goal?(x, y)
    return false if not_open?(x, y)
    mark_as_part_of_solution_path(x, y)
    return true if find_path(x, y - 1) # North of (x, y)
    return true if find_path(x + 1, y) # East of (x, y)
    return true if find_path(x, y + 1) # South of (x, y)
    return true if find_path(x - 1, y) # West (x, y)
    unmark_as_part_of_solution_path(x, y)
    false
  end

  def solvable?
    find_start_point
    find_path(@row, @column)
  end

  def steps
    solvable? unless @row && @column
    @steps
  end

end