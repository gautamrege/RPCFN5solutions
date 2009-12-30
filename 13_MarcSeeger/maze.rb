class Maze
	def initialize(ascii_maze)

		#used to store start + end info
		@maze_info = Hash.new
		
		#used to store a 2d array representation of the maze
		@maze_array = Array.new
		
		#used to store data where the solving algorithm has been in the maze
		@been_there = Array.new
		
		#this is the shortest path, destilled by filtering loops from @been_there
		@steps = Array.new
		
		#if we find a solution, this will be set to true
		@found_way_to_the_exit = false
	
		#let's convert the ascii maze to a 2 dimensional array
		#also: take a note where start and exit are
		current_index = 0
		ascii_maze.each_line do |line|
			current_line = line.chomp.split("")
			@maze_array << current_line
			@maze_info["maze_start"] = [current_index, current_line.index("A")] if current_line.include?("A")
			@maze_info["maze_exit"] =  [current_index, current_line.index("B")] if current_line.include?("B")
			current_index += 1
		end
		
		#start the algorithm (fills @been_there and @found_a_way_to_the_exit)
		self.find_exit(@maze_info["maze_start"])
		
		#now let's look for the actual shortest path, we basically elimitate loops from @been_there
		@been_there.each do |step|
				if !@steps.include?(step)
					@steps << step
				else
					@steps = @steps[0..@steps.index(step)]
				end	
			end
	
	
	end
	
	def pretty_print(maze = @maze_array)
	#just print out a visual representation of the maze
	#also used in movie_time
		maze.each do |line|
			puts line.join(" ")
		end
	end
	
	def movie_time(optimal = true)
	#show the shortest path in a movie :)
		movie_array = @maze_array
		
		#do we want the ACTUAL way the algorithm looked for the exit or just the shortest (optimal) path?
		if optimal
			move_list = @steps
		else
			move_list = @been_there	
		end		
		
		move_list.each do |step|
			movie_array[step[0]][step[1]] = "X"
			puts "\e[H\e[2J"
			self.pretty_print(movie_array)
			puts "Current position: #{step.inspect}"
			puts "Distance to exit (#{@maze_info["maze_exit"].inspect}): #{aerial_point_distance(step, @maze_info["maze_exit"])}"
			puts "possible moves:"
			self.possible_moves(step).each do |possibility|
				puts "#{possibility.inspect} --> distance to exit: #{aerial_point_distance(possibility[1], @maze_info["maze_exit"])}"
			end
			sleep 0.1

			puts @maze_info.inspect
			puts "used #{move_list.size - 1} steps to arrive at #{move_list.last}"
		end
	end


	def aerial_point_distance(position1, position2)
	#calculates the direct distance between two points in a maze
		distance = 0
		#vertical distance
		distance += (position1[0] - position2[0]).abs
		#horizontal distance
		distance += (position1[1] - position2[1]).abs
		#return accumulated distance
		distance
	end

	def possible_moves(current_pos)
		#will return an array of possible moves and their resulting coordinates from position current_pos such as:
		#[  ["up", [5,9]] , ["left", [4,8]]  ]
	
		possible_array = Array.new
		if @maze_array[current_pos[0] - 1][current_pos[1]] != "#"
			possible_array << ["up", [current_pos[0] - 1, current_pos[1]]]
		end
	
		if @maze_array[current_pos[0] + 1][current_pos[1]] != "#"
			possible_array << ["down", [current_pos[0] + 1, current_pos[1]]]
		end
	
		if @maze_array[current_pos[0]][current_pos[1] - 1] != "#"
			possible_array << ["left", [current_pos[0], current_pos[1] - 1]]
		end
	
		if @maze_array[current_pos[0]][current_pos[1] + 1] != "#"
			possible_array << ["right", [current_pos[0], current_pos[1] + 1]]
		end

		#let's sort the moves by aerial distance to the exit... might make things quicker on big mazes
		possible_array.sort{|pos1,pos2| self.aerial_point_distance(pos1[1],@maze_info["maze_exit"]) <=> self.aerial_point_distance(pos2[1],@maze_info["maze_exit"]) }
	end

	def find_exit(current_pos)
		#let's iterate though all the possibles moves from our current direction
		#we'll only look at moves that lead to a position we haven't been at so far
		#for each new position, we'll look (recursively) for possible moves again
		#we quit once we find the exit marked "B" or once we run out of moves
		
		possible_moves(current_pos).each do |direction|
			#if we already set the found flag, we might as well quit :)
			break if @found_way_to_the_exit

			if @been_there.include?(direction[1])
				#We've already been in this direction, no need to try again
				next
			else
				#yay, a new direction we haven't been at so far
			
				#let's add this to our array of visited coordinates
				@been_there << current_pos
			
				#let's check if we've arrived at the exit
				if @maze_array[direction[1][0]][direction[1][1]] == "B"
					@found_way_to_the_exit = true
					#add our last step to the @been_there array
					@been_there << [direction[1][0],direction[1][1]]
					break
				else
					#not at the exit yet, let's try again using recursion
					self.find_exit(direction[1])
				end
			end	
		end
	end

	def solvable?()
		@found_way_to_the_exit
	end

	def steps
		if @found_way_to_the_exit == false
			return 0
		else
			#because I actually count the amount of coordinates we pass, we have to subtract 1
			return @steps.size - 1		
		end
	end
	
	def print_steps_list
				@steps.each{|step| print "#{step.inspect} -> "}
	end
end