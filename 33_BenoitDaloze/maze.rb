#!/usr/bin/env ruby -Ku
# encoding: utf-8
=begin
Benoit Daloze
RPCFN5 : Mazes

I extended the test suite, with small but harder examples.
I think the tests should have provided more mazes(bigger), to get an idea about the speed

Point represent a palce in the maze, by @x and @y.
It is just a coordinate system to ease the process.

I got kind of an issue, as I create 2-3 instances of every Point,
 while one is far enough(even for multiple mazes).
Keeping them in an Array is too expensive in time,
 but my which was to rewrite Point.new to return an existing Point if there is.

I used 2 kind of methods to solve this challenge
1) The tree and get_all_paths, get_paths_to_arrival and get_path_to_arrival
  I build paths using a simple Tree structure and then
  I just look if a parent node doesn't include already the Point, to not make circular paths
  The first method, get_all_paths, is quite slow when there are many possible paths
    (which is not the case in the test suite given)
  The two others are taking only the interesting part of the Tree.
  The last is quite good compared to dijkstra

2) Dijkstra's algorithm with dijkstra, dijkstra_to_arrival and dijkstra_optimized
  There is the dijkstra algorithm for this case (with adjacent cells)
=end

# tree.rb
module Tree
	class Node
		attr_accessor :args, :parent, :children

		def initialize(*args)
			@args = args
			@parent = nil
			@children = []
		end
		
		def name
			@args.first
		end

		def == o
			(o.is_a?(Node) and @args == o.args) or
			@args.include?(o)
		end

		def << child
			case child
			when Node
				@children << child
				child.parent = self
				child
			when Array
				child.each { |c| self << c }
				self
			else
				self << Node.new(child)
			end
		end

		def root
			root? ? self : @parent.root
		end

		# Boolean
		def root?
			@parent.nil?
		end
		def parent?(p)
			ascendants.include?(p)
		end
		def leaf?
			@children.empty?
		end

		# selectors
		def all
			root.descendants
		end
		def ascendants # [self, parent, ..., root] array of ancestors in reverse order, includes self
			root? ? [self] : [self] + parent.ascendants
		end
		def descendants # [self, child1, ...] includes self
			@children.inject([self]) { |desc, c| desc + c.descendants } rescue []
		end

		def leafs
			descendants.select { |n| n.leaf? }
		end

		def single_tree # return a tree containing only this node and his parents
			ascendants.reverse[1..-1].inject(Tree.new(*root.args)) { |t, n|
				t.leafs[0] << Node.new(*n.args)
			}
		end

		def linearize
			descendants.select { |n| n.leaf? }.map { |n| n.ascendants.reverse }
		end
	end
	
	def new(*args)
		Node.new(*args)
	end
	module_function :new
end

################################
# maze.rb
include Tree

module Kernel
	def ∈(set)
		set.include?(self)
	end
end

class Point
	attr_reader :x, :y
	def initialize(x, y)
		@x, @y = x, y
	end
	
	def + c
		Point.new(@x + c.x, @y + c.y)
	end
	
	def == o
		# Should also include o.is_a?(Point), but it's very slower
		@x == o.x and @y == o.y
	end
	
	# Hash stuff
	alias :eql? :==
	def hash
		@x ^ @y
	end
	
	def to_s
		"(#{@x},#{@y})"
	end
end

class Maze
	WALL = '#'
	GROUND = ' '
	DEPARTURE = 'A'
	ARRIVAL = 'B'
	
	DIRECTIONS = [
		Point.new( 0, -1), # north
		Point.new( 1,  0), # east
		Point.new( 0,  1), # south
		Point.new(-1,  0)  # west
	]
	
	Infinity = +1.0/0.0

	def initialize(maze)
		@maze = maze.sub(/\A\n(.+)\Z/, '\1').lines.with_index.map { |l, y|
			l.chomp.chars.with_index.map { |c, x|
				case c
				when WALL      then :wall
				when GROUND    then :ground
				when DEPARTURE
					@d = Point.new(x,y)
					:departure
				when ARRIVAL
					@a = Point.new(x,y)
					:arrival
				else
					raise "Unknown character in maze's string: #{c}"
				end
			}
		}
		
		@reachable = {}
	end
	
	def to_s
		@maze.map { |l|
			l.map { |c|
				case c
				when :wall then WALL
				when :ground then GROUND
				when :departure then DEPARTURE
				when :arrival then ARRIVAL
				end
			}.join
		}.join("\n")
	end
	
	def [](c)
		return :wall unless c.y.∈(0...@maze.length) and c.x.∈(0...@maze[c.y].length)
		@maze[c.y][c.x]
	end
	
	def solvable?
		@a.∈ all_reachable
	end
	
	# Return (example) {(1,0)=>:wall, (0,1)=>:ground, (-1,0)=>:wall, (0,-1)=>:ground}
	# {Point => Symbol} of neighbours of c with their states
	def neighbors(c)
		DIRECTIONS.inject({}) { |h, d|
			h.merge({d => self[c + d]})
		}
	end
	
	# [Point] that can be reached from c
	def reachable(c)
		@reachable[c] ||= DIRECTIONS.inject([]) { |r, d|
			next(r) if self[p = c + d] == :wall
			r << p
		}.freeze
	end
	
	def all_reachable
		@all_reachable ||= begin
			to_look = [@d]
			looked = [@d]
			while c = to_look.pop
				to_look += reachable(c).reject { |r| r.∈ looked }
				looked << c
			end
			looked
		end
	end
	
	def get_all_paths
		t = Tree.new(@d)
		# A leaf is a node without parent in a Tree
		# here it is a Point without reachebale Point next to it (or who has not been looked yet)
		until t.leafs.all? { |leaf|
				# We don't want to go at the same Point we passed
				leaf << reachable(leaf.name).reject { |c| leaf.parent?(c) }
				leaf.leaf? # Did we found any Point reacheable ?
			}
		end
		t
	end
	
	def get_paths_to_arrival
		t = Tree.new(@d)
		until t.leafs.all? { |leaf|
				unless leaf == @a
					leaf << reachable(leaf.name).reject { |c| leaf.parent?(c) }
				end
				leaf.leaf?
			}
		end
		t
	end
	
	def get_path_to_arrival # Notice the singular
		t = Tree.new(@d)
		loop do
			t.leafs.each { |leaf|
				# We can be sure this is the shortest, as we advance step by step for each path
				return leaf.single_tree if leaf == @a
				leaf << reachable(leaf.name).reject { |c| leaf.parent?(c) }
				leaf.leaf?
			}
		end
	end
	
	def select_shortest_path(paths)
		paths.linearize.
		select { |path| @a.∈ path }.
		map { |p|
			p[0...p.index(@a)] # let's take the part to the arrival, we won't go further
		}.map(&:length).min # And get the length of shortest one
	end
	
	def steps(method = :do)
		return 0 if not solvable?

		case method
		when :dijkstra, :d
			dijkstra[@a]
		when :dijkstra_to_arrival, :da
			dijkstra_to_arrival[@a]
		when :dijkstra_optimized, :do
			dijkstra_optimized
		else
			select_shortest_path(send(method))
		end
	end
	
	def dijkstra
		dist = Hash.new(Infinity) # Unknown distance function from source to v
		prev = {} # Previous node in optimal path from source
		dist[@d] = 0 # Distance from source to source
		q = all_reachable.dup # All nodes in the graph are unoptimized - thus are in Q
		
		until q.empty?
			u = q.min_by { |v| dist[v] } # vertex in Q with smallest dist
			break if dist[u] == Infinity # all remaining vertices are inaccessible from source
			q.delete(u)
			
			reachable(u).each do |v| # where v has not yet been removed from Q
				alt = dist[u] + 1 # dist_between(u, v) = 1 because they are neighbors
				if alt < dist[v] # Relax (u,v,a)
					dist[v] = alt
					prev[v] = u
				end
			end
		end
		dist
	end
	
	def dijkstra_to_arrival # return when we reach arrival
		dist = Hash.new(Infinity)
		prev = {}
		dist[@d] = 0
		q = all_reachable.dup
		
		until q.empty?
			u = q.min_by { |v| dist[v] }
			return dist if u == @a
			break if dist[u] == Infinity
			q.delete(u)
			reachable(u).each do |v|
				alt = dist[u] + 1
				if alt < dist[v]
					dist[v] = alt
					prev[v] = u
				end
			end
		end
	end
	
	def dijkstra_optimized # Without prev {}
		dist = Hash.new(Infinity)
		dist[@d] = 0
		q = all_reachable.dup
		
		until q.empty?
			u = q.min_by { |v| dist[v] }
			return dist[@a] if u == @a
			q.delete(u)
			reachable(u).each do |v|
				alt = dist[u] + 1
				dist[v] = alt if alt < dist[v]
			end
		end
	end
end

=begin  # commented out by ashbb
################################
# test_maze.rb
require 'test/unit'

MAZE1 = %{
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
#####################################}
# Maze 1 should SUCCEED

MAZE2 = %{
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
#####################################}
# Maze 2 should SUCCEED

MAZE3 = %{
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
#####################################}
# Maze 3 should FAIL

### Perso
MAZE4 = '
########
#A     #
###### #
#   B# #
# #### #
#      #
########
' # 19

MAZE5 = '
############
#      #####
# ##       #
# B####    #
####  #### #
#A         #
############
' # 25

MAZE6 = '
#############
#A         B#
######  #####
#############
' # 10

MAZE7 = '
#######
#     #
#A B  #
#     #
#######
' # 2

MAZE8 = '
     
  #  
A # B
' # 8

MAZE9 = '
  #
 #A#
#   #
 #B#
  #
' # 2

MAZE10 = '
A
 
 
       B
' # 10

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
	
	def test_perso
		assert_equal 19, Maze.new(MAZE4).steps
		assert_equal 25, Maze.new(MAZE5).steps
		assert_equal 10, Maze.new(MAZE6).steps
		assert_equal 2, Maze.new(MAZE7).steps
	end
	
	def test_without_ext_walls
		assert_equal 8, Maze.new(MAZE8).steps
	end
	
	def test_not_rectangular
		assert_equal 2, Maze.new(MAZE9).steps
	end
	
	def test_open
		assert_equal 10, Maze.new(MAZE10).steps
	end
end

# Time on my laptop for each method (ruby 1.9.2)
# 0.105 dijkstra_optimized
# 0.107 dijkstra_to_arrival
# 0.119 dijkstra
# 0.166 get_path_to_arrival
# 2.154 get_paths_to_arrival
# 6.533 get_all_paths: 7.51
=end