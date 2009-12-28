# Solves mazes using classic painting algorithm.
# 
# @example
#   Maze.new(MAZE1).solvable?
#   Maze.new(MAZE1).steps
# 
class Maze
  # Parses maze provided as a string showing a graphical
  # representation of the maze’s layout.
  # 
  # Internal representation of the maze is an Array of Integers,
  # where -1 is a wall, 0 is a space, 1 is a starting point.
  # 
  def initialize(maze)
    maze = maze.split("\n")
    @height = maze.size
    @width = @height > 0 ? maze[0].size : 0

    @maze = Array.new(@height) { Array.new(@width) }
    for i in 0...maze.size
      for j in 0...maze[i].size
        @maze[i][j] = parse_cell(maze, i, j)
      end
    end
  end

  # Returns true/false depending on whether it's possible to
  # navigate the maze from point A to point B.
  # 
  def solvable?
    trace_steps > 0
  end

  # Returns an integer of the least number of "steps" one would
  # have to take within the maze to get from point A to point B.
  # "Steps" can only be taken up, down, left or right. No diagonals.
  # 
  def steps
    trace_steps
  end

  private

    # Returns an Integer value corresponding to the symbol
    # from an original maze string.
    # 
    def parse_cell(maze, row, col)
      case maze[row][col]
        when ?#: -1
        when ?A: 1
        when ?B
          @exit_x = col
          @exit_y = row
          0
        when 32: 0
        else
          raise ArgumentError, "Maze is invalid!"
      end
    end

    # Painting algorithm implementation.
    # 
    def trace_steps
      return @steps if defined?(@steps)

      more_steps = true
      current_step = 1
      while more_steps
        more_steps = fill_next_step(current_step)
        break if @maze[@exit_y][@exit_x] > 0
        current_step += 1
      end

      @steps = @maze[@exit_y][@exit_x] > 0 ? @maze[@exit_y][@exit_x] - 1 : 0
    end

    # Fills free cells around ones with the value current_step
    # with the value (current_step + 1).
    # 
    def fill_next_step(current_step)
      more_steps = false
      for i in 0...@height
        for j in 0...@width
          next unless @maze[i][j] == current_step

          if i > 0 && @maze[i - 1][j] == 0
            @maze[i - 1][j] = current_step + 1
            more_steps = true
          end
          if i < @height - 1 && @maze[i + 1][j] == 0
            @maze[i + 1][j] = current_step + 1
            more_steps = true
          end
          if j > 0 && @maze[i][j - 1] == 0
            @maze[i][j - 1] = current_step + 1
            more_steps = true
          end
          if j < @width - 1 && @maze[i][j + 1] == 0
            @maze[i][j + 1] = current_step + 1
            more_steps = true
          end
        end
      end
      more_steps
    end
end