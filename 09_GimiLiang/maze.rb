# RPCFN #5: Mazes
# @author 梁智敏(Gimi Liang) [gimi.liang at gamil dot com]
# @date 2009/12/29
class Maze
  START_POINT_MARKER = 'A'.freeze
  END_POINT_MARKER   = 'B'.freeze
  INFINITE           = (1.0 / 0.0).freeze

  class Cell
    WALL = '#'.unpack('c').first.freeze

    attr_reader :maze, :x, :y, :type

    def initialize(maze, x, y)
      @maze = maze
      @x, @y = x, y
      @type = maze.at(x, y)
    end

    def east;  @east  ||= maze.cell(self.x + 1, self.y) end

    def south; @south ||= maze.cell(self.x, self.y + 1) end

    def west;  @west  ||= maze.cell(self.x - 1, self.y) end

    def north; @north ||= maze.cell(self.x, self.y - 1) end

    # returns all neighbors of this cell.
    # @param [Boolean] navigable_only if it's true, only returns neighbors that are navigable.
    def neighbors(navigable_only = true)
      [:east, :south, :west, :north].inject([]) do |neighbors, direction|
        (cell = send direction) &&
        (!navigable_only || cell.navigable?) &&
        neighbors << cell || neighbors
      end
    end

    def navigable?
      type != WALL
    end

    def eql?(other)
      other.is_a?(Cell)  &&
      maze == other.maze &&
      x == other.x &&
      y == other.y
    end

    def to_s
      "(#{x}, #{y})"
    end

    alias inspect to_s
  end # Cell

  # Create a maze with a maze string.
  def initialize(maze_string)
    @cells = {}
    parse maze_string
  end

  def solvable?
    steps != 0
  end

  def steps
    @steps ||= (step = process) == INFINITE ? 0 : step
  end

  def cell(x, y)
    @cells.has_key?([x, y]) ? @cells[[x, y]] :
      @cells[[x, y]] = exists?(x, y) ? Cell.new(self, x, y) : nil
  end

  # Returns the value of a cell by its axes.
  def at(x, y)
    x < 0 || y < 0 ? nil : (row = @maze[y]) && row[x]
  end

  def exists?(x, y)
    not at(x, y).nil?
  end

  private
  # Turns a maze string into a 2-dimension array and marks the start point and the end point.
  def parse(maze_string)
    y = -1
    start_axes = end_axes = nil
    @maze = maze_string.each_line.map do |line|
      y += 1
      (x = line.index(START_POINT_MARKER)) && start_axes = [x, y]
      (x = line.index(END_POINT_MARKER))   && end_axes   = [x, y]
      line.unpack 'c*'
    end
    @start_point = cell *start_axes if start_axes
    @end_point   = cell *end_axes   if end_axes
  end

  # Figure out the least steps from start point to end point using Dijkstra's algorithm.
  # @return [Integer] steps if the maze is unsolvable, return Infinite.
  def process
    return INFINITE unless @start_point && @end_point
    sources = [@start_point]
    next_sources = @start_point.neighbors
    (steps = Hash.new { |h, k| h[k] = INFINITE })[@start_point] = 0
    until next_sources.empty?
      source = next_sources.first
      next_sources.concat(
        source.neighbors.each do |neighbor|
          step = steps[neighbor] + 1
          steps[source] = step if step < steps[source]
        end
      )
      return steps[@end_point] if source == @end_point
      sources << source
      next_sources -= sources
    end
    steps[@end_point]
  end

end

# --- TESTS -------------------------------------------------------------------
if $0 == __FILE__
  require 'test/unit'

  MAZE1 = <<MAZE_1 # should SUCCEED
#####################################
# #   #     #A        #     #       #
# # # # # # ####### # ### # ####### #
# # #   # #         #     # #       #
# ##### # ################# # #######
#     # #       #   #     # #   #   #
##### ##### ### ### # ### # # # # # #
#   #     #   # #   #  B# # # #   # #
# # ##### ##### # # ### # # ####### #
# #     # #   # # #   # # # #       #
# ### ### # # # # ##### # # # ##### #
#   #       #   #       #     #     #
#####################################
MAZE_1

  MAZE2 = <<MAZE_2 # should SUCCEED
#####################################
# #       #             #     #     #
# ### ### # ########### ### # ##### #
# #   # #   #   #   #   #   #       #
# # ###A##### # # # # ### ###########
#   #   #     #   # # #   #         #
####### # ### ####### # ### ####### #
#       # #   #       # #       #   #
# ####### # # # ####### # ##### # # #
#       # # # #   #       #   # # # #
# ##### # # ##### ######### # ### # #
#     #   #                 #     #B#
#####################################
MAZE_2

  MAZE3 = <<MAZE_3 # should FAIL
#####################################
# #   #           #                 #
# ### # ####### # # # ############# #
#   #   #     # #   # #     #     # #
### ##### ### ####### # ##### ### # #
# #       # #  A  #   #       #   # #
# ######### ##### # ####### ### ### #
#               ###       # # # #   #
# ### ### ####### ####### # # # # ###
# # # #   #     #B#   #   # # #   # #
# # # ##### ### # # # # ### # ##### #
#   #         #     #   #           #
#####################################
MAZE_3

  class MazeTest < Test::Unit::TestCase
    def test_good_mazes
      assert_equal true, Maze.new(MAZE1).solvable?
      assert_equal true, Maze.new(MAZE2).solvable?
    end

    def test_bad_mazes
      assert_equal false, Maze.new(MAZE3).solvable?
    end

    def test_maze_steps
      assert_equal 44, Maze.new(MAZE1).steps
      assert_equal 75, Maze.new(MAZE2).steps
      assert_equal 0, Maze.new(MAZE3).steps
    end
  end
end