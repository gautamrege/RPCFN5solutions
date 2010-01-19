# cf. http://rubylearning.com/blog/2009/12/27/rpcfn-mazes-5/

class Coord

	attr_accessor :x, :y
	
	def initialize(x, y)
		@x, @y = x, y
	end
	
	def +(coord)
		return Coord.new(@x+coord.x, @y+coord.y)
	end
	
end

WALL = '#'
FREE = ' '
STARTPOINT = 'A'
ENDPOINT = 'B'
INSPECTED = '*'
DIRECTIONS = {:No => Coord.new(0,-1), :We => Coord.new(-1,0), :So => Coord.new(0,1), :Ea => Coord.new(1,0)} # North, West, South, East

class Maze
	
	attr_reader :maze
	attr_accessor :solutions
	
	def initialize(maze, display=false)
		@display = display
		@maze = maze.split(/\n/).collect{|line| line.split(//)} # @maze[line][column]
		@solutions = []
		Explorer.new(self, self.start_coord, []).explore
	end
	
	def start_coord
		start_line = @maze.index(@maze.find{|line| line.include?(STARTPOINT)})
		start_column = @maze[start_line].index(STARTPOINT)
		return Coord.new(start_column, start_line) # Coord(x,y)
	end
	
	def to_s
		if @display
			sleep 0.05
			(@maze.collect {|row| row.join(' ')} + ['-'*40]).join("\n")
		end
	end
	
	def solvable?
		not @solutions.empty?
	end
	
	def steps
		@solutions.collect {|s| s.size}.min || 0
	end
	
	def [](coord)
		@maze[coord.y][coord.x]
	end
	
	def []=(coord, value)
		@maze[coord.y][coord.x] = value
	end
	
end

class Explorer
	
	def initialize(maze, coord, path)
		@maze, @coord, @path = maze, coord, path
	end
	
	def explore
		DIRECTIONS.each_pair do |direction, step_coord|
			spot_coord = @coord+step_coord
			
			case @maze[spot_coord]
			when FREE
				puts @maze
				@path << direction
				@maze[spot_coord] = INSPECTED
				Explorer.new(@maze, spot_coord, @path).explore
				@maze[spot_coord] = FREE
				@path.pop
			when ENDPOINT
				@path << direction
				@maze.solutions << @path.dup
				return
			end
		end
		return false
	end
	
end


if __FILE__ == $0
MAZE4 = %{#####################################
# #       #             #     #     #
# ### ### # ########### ### # ##### #
# #   # #   #   #   #   #   #       #
# # ###A##### # # # # ### ###########
#   #   #     #   # # #   #         #
####### # ### ####### # ### ####### #
#       # #   #       # #       #   #
# ####### # # # ####### # ##### # # #
#       # # # #   #       #   # #   #
# ##### # # ##### ######### # ### # #
#     #   #                 #     #B#
#####################################}

m = Maze.new(MAZE4, true)
puts m.steps
end