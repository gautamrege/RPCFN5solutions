# Solution for the Ruby Challenge: http://rubylearning.com/blog/2009/12/27/rpcfn-mazes-5/
# By Dmitriy Nagirnyak
# The class is responsible for solving arbitrary maze by searching for the smallest number of steps required to move from point A to B
class Maze
	StartMark = 'A'
	EndMark = 'B'
	SpaceMarks = [' ', EndMark, StartMark]

	# Initializes the solver accepting the maze as a string.
	# The string can contain a number of rows separated by '\n' character. The length of the rows can be different.
	# Start and end positions are marked with A and B respectively.
	# Movable area is the one that contains space, A  or B marks.
	def initialize(maze)
		# Build the 2D area, like this: [%w{# # #}, %w{#A#}, %w{#B#}]
		@area = maze.split(/\r?\n/).map {|r| r.split(//) }
		#Find start & the end - 2 arrays with coordinates: [row,column]
		@area.each_with_index do |r, ri|
			r.each_with_index do |c, ci|
				@start = [ri,ci] if c == StartMark
				@end = [ri,ci] if c == EndMark
				break if @start && @end
			end
			break if @start && @end
		end
		throw ArgumentError.new('No start and/or end positinos provided on the maze') if !@start || !@end
	end
	
	# Returns minimal number of steps required to move from position marked as A to position B on the maze.
	def steps
		res = calc_steps @start, []
		# Always includes step for A, thus minumal value if solution exists is 2	
		res > 0 ? res-1 : 0
	end
	
	# Returns true if there is a path from A to B. Otherwise false.
	def solvable?
		steps > 0
	end
	
	
	private
	
	# The main worker - recursively finds the smallest number of steps
	def calc_steps(cur, traces)
		# Recursion bases
		return 0 if !can_move_to cur # hit the wall
		return 0 if traces.include? cur #been here
		return 1 if cur == @end #found the guy
		
		# Keep the local copy of the traces, also adding current position to it
		cur_traces = traces.map {|e| e}.push cur		
		
		# Recursion step
		left = calc_steps from_left(cur), cur_traces
		right = calc_steps from_right(cur), cur_traces
		up = calc_steps from_up(cur), cur_traces
		dn = calc_steps from_dn(cur), cur_traces
		
		# Reject zero steps and get the minimal value if available
		sub_steps = [left, right, up, dn].reject! {|step| step <= 0 }.min		
		# return the total number of steps keeping in mind:  no sub_steps  means no way to the guy, thus zero
		sub_steps ? sub_steps + 1 : 0
	end
	
	# Returns the new coordinates with the given offset
	def move(pos, down, right)
		[pos[0] + down, pos[1] + right]
	end	
	# Sugar - position on the left from current
	def from_left(cur)
		move(cur, 0, -1)
	end	
	# Sugar - position on the right from current
	def from_right(cur)
		move(cur, 0, 1)
	end
	# Sugar - position on the front from current
	def from_up(cur)
		move(cur, -1, 0)
	end
	# Sugar - position on the back from current
	def from_dn(cur)
		move(cur, 1, 0)
	end
	
	# Checks if the given position is movable (so that a guy can step onto it)
	def can_move_to(pos)
		return false if pos[0] < 0 || pos[1] < 0
		return false if pos[0] >= @area.length			
		row = @area[pos[0]]		
		return false if pos[1] >= row.length	
		SpaceMarks.include? from_area(pos)
	end
	
	# Returns the mark located at the given position of the area.
	# It doesn't check out-of-bounds conditions. Use can_move_to for that.
	def from_area(pos)
		@area[pos[0]][pos[1]]
	end
end