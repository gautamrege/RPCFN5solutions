class Maze
  def initialize(maze)
    raise ArgumentError, "Invalid maze." if maze.nil? or maze.empty? or not maze.include?("\n")
    @maze_width = maze.index("\n")
    @maze = maze.gsub("\n", '').split(//) # The maze is represented as an array.
  end

  def solvable?
    path_finder(@maze.index('A'))
  end

  protected

  # Recursively determines if from _here_ we can reach the end of the maze
  # by looking at the adjacent cells (Up, Down, Left and Right). Moreover, cells that have
  # already been visited are tracked so we don't repeat ourselfs.
  #
  #   here:           starting index in the maze
  #   visited_cells:  the indicies that were already visited during the path search.
  def path_finder(here, visited_cells=[])
    return false if out_of_bounds?(here) or visited_cells.include?(here) or @maze[here] == "#"
    return true if @maze[here] == 'B'
    visited_cells << here
    return (path_finder(here-1, visited_cells) or path_finder(here+1, visited_cells) or path_finder(here-@maze_width, visited_cells) or path_finder(here+@maze_width, visited_cells))
  end

  # Determine if it's a valid location in the maze.
  def out_of_bounds?(index)
    return (index >= @maze.length or index < 0) ? true : false
  end
end