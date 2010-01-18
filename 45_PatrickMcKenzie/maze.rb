#This solves the maze using regular expressions, because I am too
#lazy to worry about arrays, darn it.  It is inefficient as heck and designed
#purely to demonstrate perversion of sound CS principals.
#
# Code by Patrick McKenzie, 2010.  I release this work unto the public domain.

class Maze
  def initialize(maze_string)
    @width = maze_string.split("\n")[0].length  #width of maze in characters
    @guts = maze_string.gsub("\n", "")          #maze as a flat string -- no newlines
    @size = @guts.length                        #Sanity check, ho.
  end

  #Use regular expressions to do a single step in any possible direction from
  #any square on the board reachable from a square previously reached. 
  #
  #Uses C to mark a square which we reached this turn, and reuses A to mark
  #a square already reached.
  #
  #The width of the maze in dots, minus one dot, is enough to wrap around to the
  #same column on the next row.
  #
  #Note side effect of last line returns nil if no square was marked this turn.
  #Sidenote: this could all be one regexp but even I'm not that evil.
  def floodfill_with_inefficient_magic!
    @guts.gsub!(/A /, "AC")
    @guts.gsub!(/A(#{"." * (@width - 1)}) /, 'A\1C')
    @guts.gsub!(/ A/, "CA")
    @guts.gsub!(/ (#{"." * (@width - 1)})A/, 'C\1A')
    @guts.gsub!("C", "A") #Mark all new places as reached simultaneously.
  end

  #If a square we've reached is adjacent to the exit B, game over, we win.
  def is_solved?
    @guts =~ /AB|BA|A#{"." * (@width - 1)}B|B#{"." * (@width - 1)}A/
  end

  #Implements specified API.
  def solvable?
    !(solution.nil?)
  end

  #Implements specified API.
  def steps
    solution || 0
  end

  #Caches solution to avoid solving twice if using both solvable? and steps.
  def solution
    @solution ||= solve!
  end

  #Actual logic.  Floodfill until you find the exit or floodfill returns nil,
  #which terminates the algorithm in failure.
  def solve!
    i = 1
    while (true)
      if is_solved?
        return i  #Found exit in i steps.
      else
        result = floodfill_with_inefficient_magic!
        if result.nil?
          return nil  #No new steps reached this turn, exit unreachable.
        else
          i += 1
        end
      end
    end
  end
end