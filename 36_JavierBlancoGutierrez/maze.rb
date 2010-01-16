class String
  alias_method :is_a, :==
  alias_method :is_an, :==
end

class Maze
  
  NAVIGABLE   = ' '
  WALL        = '#'
  POINT_A     = 'A'
  POINT_B     = 'B'
  
  def initialize(input)
    # builds a multidimensional array representation from the input string
    @labyrinth = input.split("\n").map { |line| line.scan(/./) }

    # finds the POINT_A coordinates
    line = @labyrinth.detect { |l| l.include?(POINT_A)}
    y = @labyrinth.index(line)
    x = line.index(POINT_A)
    @start_point = [y, x]
  end
  
  def solvable?(position = init_steps_taken_and_return_first, &block)
    # checks if we found the target position
    if at(position).is_an(POINT_B)
      # avoids unnecesary iterations when we only want to know if a maze is solvable
      return true unless block_given?
      #yields the amount of steps for this particular solution
      steps_amount = caller.grep(/solvable/).length / 2
      yield steps_amount
    end
    
    # "Steps"
    #   can only be taken up, down, left or right
    #   cannot be taken throught walls :-)
    #   shouldn't be taken more than once
    y, x = *position
    steps_available = [             [y - 1, x],
                       [ y, x - 1],             [ y, x + 1],
                                    [y + 1, x]               ]
    steps_available.reject! do |p|
      at(p).is_a(WALL) || @steps_taken.include?(p)
    end
    @steps_taken.concat(steps_available)
    
    # recursively looks for the POINT_B from each step available
    steps_available.any? { |step| solvable?(step, &block) }
  end
  
  def steps
    amounts = []
    solvable? do |amount|
      amounts << amount
    end
    amounts.min || 0
  end
  
  private
  
  def at(position)
    y, x = *position
    @labyrinth[y][x]
  end
  
  def init_steps_taken_and_return_first
    @steps_taken = [ @start_point ]
    @start_point
  end

end