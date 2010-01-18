class Maze
	
	Cardinals = Proc.new{|(x,y)| [[x-1,y],[x,y+1],[x+1,y],[x,y-1]].select{|c| c.min >= 0}}
	MazeSeperator, MazeStart, MazeWall, MazeEnd, MazeOOB = "\n", 'A', '#', 'B', nil
	Infinity = 1.0/0
	X, Y = 0, 1
	
	def initialize(maze)
		raise ArgumentError, 'No end point'          unless maze.include? MazeEnd
		raise ArgumentError, 'No start point'        unless maze.include? MazeStart
		raise ArgumentError, 'Multiple start points' unless maze.count(MazeStart) == 1
		raise ArgumentError, 'Multiple end points'   unless maze.count(MazeEnd)   == 1
		@maze = maze.split(MazeSeperator).map{|row| row.each_char.to_a} # Make a 2-d array of characters, [Y][X] (I could transpose)
		(@start = (map = @maze.map{|a| a.index MazeStart}).compact) << map.index(@start.first) # [X,Y]
	end
	
	def solvable?
		@solvable ||= (solution(false) != Infinity) # solution(false) doesn't continue searching for the shortest route, it's happy with just one solution
	end
	
	def steps
		@steps ||= (solvable? && solution(true) || 0) # look for the shortest solution, if solvable? then memoize
	end
	
private

	def solution(shortest_path, path = [@start])
		# Check to see where we are, being mindful of "out of bounds"
		case (point = path.last) && (@maze[point[Y]][point[X]] rescue MazeOOB)
		when MazeWall, MazeOOB
			Infinity    # If we have hit a wall or gone out of bounds, no good can come of it
		when MazeEnd
			path.size-1 # Don't count the first node
		else
			if path.count(point) > 1
				Infinity # If we've doubled back, we are done for
			else
				# While adding some complexity, breaking out when a solution is found (if not looking for the shortest route) 
				# makes testing for solvability quicker
				Cardinals.call(point).inject([]) do |collection, new_location|
					(shortest_path || collection.empty? || collection.min == Infinity) &&  # If we haven't already found a solution, or we are looking for the shortest route
						(collection << solution(shortest_path, path.dup << new_location)) || #   Use the force Luke
					collection                                                             # Else GTFO
				end.min # Grab the shortest route
			end
		end
	end

end