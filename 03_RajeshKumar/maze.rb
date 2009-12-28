class Maze
  def initialize(maze_string)
    @maze = maze_string.split("\n")
    @maze = @maze.map do |maze|
      maze_row = []
      maze.each_char do |c|
        maze_row << {
          :is_wall => (c == "#"),
          :dist_A => (c == "A" ? 0 : nil),
          :dist_B => (c == "B" ? 0 : nil)
        }
      end
      maze_row
    end
    
    @maze_string = maze_string
  end
  
  def rows
    @maze.size
  end
  
  def cols
    @maze[0].size
  end
  
  def position_A
    row, col = position("A")
    position("A")
  end
  
  def position_B
    row, col = position("B")
    position("B")
  end
  
  def find_non_wall_neighbor(row, col)
    [
       neighbor(row-1, col),
       neighbor(row, col+1), 
       neighbor(row+1, col), 
       neighbor(row, col-1)
    ].compact
  end

  def neighbor(row, col)
    row_col_within_bounds(row, col) && @maze[row][col][:is_wall] != true ? [row, col] : nil
  end
  
  def row_col_within_bounds(row, col)
    0 <= row && rows >= row && 0 <= col && cols >= col 
  end
  
  def position(str)
    pos = @maze_string.index(str)
    return pos/(cols+1), (pos % (cols+1) )
  end
  
  def solvable?
    solvable, steps = solve
    solvable
  end
  
  def steps
    solvable, steps = solve
    steps
  end
  
  def solve
    nearest_neighbors_a = [position_A]
    nearest_neighbors_b = [position_B]
    
    solvable = false
    steps = 0
    while (!nearest_neighbors_a.empty? || !nearest_neighbors_b.empty?)
      solvable, steps, nearest_neighbors_a = take_one_step("A", nearest_neighbors_a)
      solvable, steps, nearest_neighbors_b = take_one_step("B", nearest_neighbors_b)
      break if solvable
    end

    return solvable, steps
  end
  
  def take_one_step(str_node, nearest_neighbors)
    other_node = str_node == "A" ? "B" : "A"

    new_nearest_neighbors = [] 
    solvable = false
    steps = 0
    
    nearest_neighbors.each do |neighbor|
      neighbor_node = @maze[neighbor[0]][neighbor[1]]
      node_neighbors_coords = find_non_wall_neighbor(neighbor[0], neighbor[1])
      
      node_neighbors_coords.each do |current_node_coords|
        
        current_node = @maze[current_node_coords[0]][current_node_coords[1]]
        
        # see if its already near other node, if yes hurray!
        if !current_node["dist_#{other_node}".to_sym].nil?
          solvable, steps = true, 1 + current_node["dist_#{other_node}".to_sym] +
            neighbor_node["dist_#{str_node}".to_sym]
          break
        elsif current_node["dist_#{str_node}".to_sym].nil?
          current_node["dist_#{str_node}".to_sym] = neighbor_node["dist_#{str_node}".to_sym] + 1
          new_nearest_neighbors << current_node_coords
        end
        
      end
      break if solvable
    end
    
    return solvable, steps, new_nearest_neighbors
  end
  
end


=begin

require 'test/unit'
require 'maze'

MAZE1 = %{#####################################
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
#####################################}
# Maze 1 should SUCCEED

MAZE2 = %{#####################################
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
#####################################}
# Maze 2 should SUCCEED

MAZE3 = %{#####################################
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
#####################################}
# Maze 3 should FAIL

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
    
  def test_find_non_wall_neighbor
    good_maze =  Maze.new(MAZE1)
    
    assert_equal [], good_maze.find_non_wall_neighbor(0, 0)
    assert_equal [[5, 1]], good_maze.find_non_wall_neighbor(5, 0)
    assert_equal [[1, 14]], good_maze.find_non_wall_neighbor(1, 13)
    assert_equal [[1,9], [3,9]], good_maze.find_non_wall_neighbor(2, 9)
  end
end
=end
