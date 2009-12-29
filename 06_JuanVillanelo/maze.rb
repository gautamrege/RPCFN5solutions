# maze.solutions will show the possible solutions if any 
class Maze
	def initialize(maze)
		@maze = maze.split("\n")
		@maze.each_with_index{|line, i| @y_ = i if line.include? "A"}
		@x_ = @maze[@y_].index("A")
		@sol = []
		solve
	end
	def solvable?
		@sol.size > 0 ? true : false
	end
	def steps
		solvable? ? @sol.inject(@sol[0].size) { |min, sol| sol.size < min ? sol.size : min } - 1 : 0
	end
	def solutions	
		if solvable?
			@sol.each_with_index do |solution, i|
				puts "\nSolution #{i+1} (#{solution.size-1} steps)"
				solution.each{|sol| print "(#{sol[0]},#{sol[1]}) "}
			end
		else puts "No solutions availables." end
	end
	private
	def solve
		@paths = [[[@y_,@x_]]]
		while @paths.size > 0
			temp = []
			@paths.each do |path|
				y, x = path.last[0], path.last[1]
				# check possible moves or solutions
				available = []
				available << [y-1, x] if @maze[y-1][x] != '#' #up
				available << [y+1, x] if @maze[y+1][x] != '#' #down
				available << [y, x-1] if @maze[y][x-1] != '#' #left
				available << [y, x+1] if @maze[y][x+1] != '#' #right
				# separate solutions from new paths
				available.each do |new|
					@sol << path + [new] if @maze[new[0]][new[1]] == 'B' #add solutions
					temp << path + [new] unless path.include? new #add new path
				end
			end
			@paths =  temp
		end
	end
end