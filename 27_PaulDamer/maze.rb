# An implementation to see if you could solve it just using regular expressions
# Paul Damer

class Maze
  DEBUG=false
  
  def initialize(maze)
    @maze = maze.dup
    @steps = 1
    @width = @maze.index("\n")
    @solvable = nil
    #detects an A next to a B
    @a_by_b = %r{BA|AB|A.{#{@width}}B|B.{#{@width}}A}m
    
    #detects a space next to an A
    @a_ajacent = %r{ (?=A)|(?<=A) | (?=.{#{@width}}A)|(?<=A.{#{@width}}) }m
    
    #detects a space surrounded on 3 sides
    @dead_end = %r{
      (?#open_right)(?<=\#.{#{@width-1}}\#)\ (?=\ .{#{@width-1}}\#)|
      (?#open_down) (?<=\#.{#{@width-1}}\#)\ (?=\#.{#{@width-1}}\ )|
      (?#open_left) (?<=\#.{#{@width-1}}\ )\ (?=\#.{#{@width-1}}\#)|
      (?#open_up)   (?<=\ .{#{@width-1}}\#)\ (?=\#.{#{@width-1}}\#)
    }mx
  end
  
  def steps
    solvable? ? @steps : 0
  end
  
  def solvable?
    return @solveable unless @solvable.nil?
    remove_dead_ends unless a_is_by_b?
    @solvable = can_get_to_b_from_a?
  end
  
  protected
  
  def a_is_by_b?
    @a_is_by_b ||= @maze.match(@a_by_b)
  end
  
  #Fill in As until you reach B
  def can_get_to_b_from_a?
    while !a_is_by_b? and @maze.gsub!(@a_ajacent, 'A') do
      @steps += 1
      puts @maze if DEBUG
    end
    a_is_by_b? ? true : false
  end
  
  def remove_dead_ends
    while @maze.gsub!(@dead_end, "#") do
      puts @maze if DEBUG
    end
  end

end