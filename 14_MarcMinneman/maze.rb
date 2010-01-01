=begin
Introduction

Mazes are known to have challenged humans from as far back as the 5th century
BC.  There are many types of maze, but typically you need to find your way from
a start point to an end point.

In this Ruby challenge, you will need to develop a class that can be used to
solve mazes. Mazes will be provided as a string showing a graphical
representation of the maze’s layout. Spaces are navigable, while # (pound)
symbols are used to denote walls. In this challenge the letter "A" is used to
mark the start point, and "B" the end point. Here’s an example of a maze
contained within a string:

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

The prior maze would be loaded into a Maze object like so:

Maze.new(MAZE1)

The Challenge

There are two parts to the challenge: you can choose to do one or both,
depending on your skill level or how much time you have available.

   1. Implement a Maze#solvable? method that returns true/false depending on
      whether it’s possible to navigate the maze from point A to point B.
   2. Implement a Maze#steps method that returns an integer of the least number
      of "steps" one would have to take within the maze to get from point A to
      point B. "Steps" can only be taken up, down, left or right. No diagonals.

There are a number of ways to "solve" mazes but there’s a wide scope for you to
be as straightforward or as clever as you like with this challenge (tip: I’d
love to see some clever/silly solutions!). Your "solvable?" and "steps" methods
could share algorithms or you might come up with alternate ways to be more
efficient in each case. Good luck!
=end

class Array
  # locate given element in 2D array and return coordinates
  def coordinates_2d(element)
    self.each_with_index do |subarray, i|
      raise ArgumentError, 'receiver object must be a 2d array' unless subarray.is_a? Array
      j = subarray.index(element)
      return i, j if j
    end
    nil
  end
end

class Maze

  def initialize(maze)
    raise ArgumentError, "Maze contains an illegal character.  Use only ['#',' ','A','B']." if maze.match(/[^#\sAB]/) #precondition
    raise ArgumentError, "Maze must include exactly one starting point (A) and one finishing point (B)." unless maze.match(/^[^A]*A[^A]*$/) && maze.match(/^[^B]*B[^B]*$/) #precondition
    @maze = maze.lines.map{|l| l.tr("\n",'').chars.to_a} # encode maze as 2D array
    raise ArgumentError, "Maze must have a walled(#) border." unless [@maze[0], @maze[-1]].inject(true) {|r,l| r&&=!l.join.match(/[^#]/)} && @maze[1..-2].inject(true) {|r,l| r&&=l[0]=='#'&&l[-1]=='#'} #precondition
    @queue = [@maze.coordinates_2d('A') << 0]  # enqueue root coordinate along with distance for bfsearch
  end

  def solvable?
    @solvable ||= bfsearch   # results are cached to minimize cost in "steps" method
  end

  def steps
    self.solvable? ? @steps : 0
  end

  private

  def bfsearch
    #  search method that implements a Breadth-First Search Algorithm
    #
    #  A maze can be viewed as a finite graph and "bfsearch"  will find the
    #  shortest path from A to B.
    #
    #  For more details see:
    #
    #  http://en.wikipedia.org/wiki/Breadth-first_search
    #
    r,c,@steps = @queue.shift       # dequeue a coordinate and distance from root
    return true if [r,c]== @finish ||= @maze.coordinates_2d('B')   # if the finish coordinate is found, quit the search and return a positive result
    (@examined ||=[]) << [r,c]      # ensure that each coordinate is examined only once
    # enqueue all successor coordinates and new distance from root coordinate
    # successor coordinates are found above [r+1,c+0], below [r-1,c+0], left [r+0,r-1], and right [r+0,r+1] of current coordinate
    [[1,0],[-1,0],[0,-1],[0,1]].each do |x, y|
      new_r, new_c, distance = r+x, c+y, @steps+1
      @queue << [new_r,new_c,distance] if !@examined.index([new_r,new_c]) && @maze[new_r][new_c].match(/[\sB]/)
    end
    return false if @queue.empty?   # If the queue is empty, every reachable coordinate in the maze has been examined, return a negative result
    bfsearch                        # recursively repeat search until a result a result is achieved
  end

end