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

SOLVABLE = {
	:one   => 'AB',
	:two   => 'A B',
	:three => 'A  B',
	:four  => 'A   B',
	:five  => 'A    B',
	:six   => 'A     B',
	:simple => %{####
# A#
# ##
# B#
####},
	:less_simple => %{####
#A #
## #
#  #
# ##
# B#
####},
	:shortest => %{#####
#B  #
# # #
#A# #
# # #
# # #
#   #
#####}
}

FAILURE = {
	:no_start => 'B',
	:no_end   => 'A',
	:multiple_end => 'ABB',
	:multiple_start => 'AAB'
}

UNSOLVABLE = {
	:stop_oob => 'A#B',
	:fool_bad_array_implementation => %{ # 
A#B
 # },
	:stop_wall => %{###
#A#
###
B  },
	:stop_loop => %{#####
#   #
# A #
#   #
#####
#B   }
}

class MazeTest < Test::Unit::TestCase
	def test_good_mazes
		SOLVABLE.keys.each {|key| assert_equal true, Maze.new(SOLVABLE[key]).solvable?}
		assert_equal true, Maze.new(MAZE1).solvable?
		assert_equal true, Maze.new(MAZE2).solvable?
	end

	def test_bad_mazes
		UNSOLVABLE.keys.each {|key|	assert_equal false, Maze.new(UNSOLVABLE[key]).solvable?}
		assert_equal false, Maze.new(MAZE3).solvable?
	end

	def test_failure
		assert_match(/No start point/,        assert_raise(ArgumentError) {Maze.new(FAILURE[:no_start])       }.message)
		assert_match(/No end point/,          assert_raise(ArgumentError) {Maze.new(FAILURE[:no_end])         }.message)
		assert_match(/Multiple end points/,   assert_raise(ArgumentError) {Maze.new(FAILURE[:multiple_end])   }.message)
		assert_match(/Multiple start points/, assert_raise(ArgumentError) {Maze.new(FAILURE[:multiple_start]) }.message)
	end
	
	def test_start_point
		assert_equal [0, 0], Maze.new(SOLVABLE[:one]  ).instance_eval('@start')
		assert_equal [0, 0], Maze.new(SOLVABLE[:two]  ).instance_eval('@start')
		assert_equal [0, 0], Maze.new(SOLVABLE[:three]).instance_eval('@start')
		assert_equal [0, 0], Maze.new(SOLVABLE[:four] ).instance_eval('@start')
		assert_equal [0, 0], Maze.new(SOLVABLE[:five] ).instance_eval('@start')
		assert_equal [0, 0], Maze.new(SOLVABLE[:six]  ).instance_eval('@start')
		assert_equal [2, 1], Maze.new(SOLVABLE[:simple]).instance_eval('@start')
		assert_equal [1, 1], Maze.new(SOLVABLE[:less_simple]).instance_eval('@start')
		assert_equal [1, 3], Maze.new(SOLVABLE[:shortest]   ).instance_eval('@start')
		assert_equal [13, 1], Maze.new(MAZE1).instance_eval('@start')
		assert_equal [7, 4],  Maze.new(MAZE2).instance_eval('@start')
		assert_equal [15, 5], Maze.new(MAZE3).instance_eval('@start')
	end
	
	def test_cardinals
		assert_equal [[0, 1], [1, 2], [2, 1], [1, 0]], Maze::Cardinals.call([1,1])
		assert_equal [[0, 1], [1, 0]],                 Maze::Cardinals.call([0,0])
	end
	
	def test_recursive_stop_cases
		maze = Maze.new(SOLVABLE[:simple])
		assert_equal Maze::Infinity, maze.send(:solution, false, [[-1,-1]])     # Testing out of bounds
		assert_equal Maze::Infinity, maze.send(:solution, false, [[0,0]])       # Testing wall hit
		assert_equal Maze::Infinity, maze.send(:solution, false, [[1,1],[1,1]]) # Testing circling
		assert_equal 0,              maze.send(:solution, false, [[2,3]])       # Testing end of maze
	end

	def test_maze_steps
		assert_equal 1,  Maze.new(SOLVABLE[:one]).steps
		assert_equal 2,  Maze.new(SOLVABLE[:two]).steps
		assert_equal 3,  Maze.new(SOLVABLE[:three]).steps
		assert_equal 4,  Maze.new(SOLVABLE[:four]).steps
		assert_equal 5,  Maze.new(SOLVABLE[:five]).steps
		assert_equal 6,  Maze.new(SOLVABLE[:six]).steps
		assert_equal 4,  Maze.new(SOLVABLE[:simple]).steps
		assert_equal 7,  Maze.new(SOLVABLE[:less_simple]).steps
		assert_equal 2,  Maze.new(SOLVABLE[:shortest]).steps # Test the shortest path
		assert_equal 12, Maze.new(SOLVABLE[:shortest]).send(:solution, false) # Test the long route
		assert_equal 44, Maze.new(MAZE1).steps
		assert_equal 75, Maze.new(MAZE2).steps
		assert_equal 0,  Maze.new(MAZE3).steps
	end
end