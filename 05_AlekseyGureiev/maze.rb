class Maze

  WALL    = '#'
  EMPTY   = ' '

  attr_reader :steps

  def initialize(spec)
    @spec = spec.split("\n").map { |line| line.split('') }
    solve
  end

  def solvable?
    steps > 0
  end
  
  private
  
  # Fill all dead ends with walls until there are none.
  # If there are empty areas -- it's our path, so count steps
  # and add one for the final step over 'B'.
  def solve
    begin
      has_updates, @steps = false, 0
      
      @spec.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          if cell == EMPTY && deadend?(x, y)
            row[x] = WALL
            has_updates = true
          end
          
          @steps += 1 if row[x] == EMPTY
        end
      end
    end while has_updates
    
    @steps += 1 if @steps > 0
  end
  
  # If more than 2 walls around, it's dead end
  def deadend?(x, y)
    [ [0, -1], [1, 0], [0, 1], [-1, 0] ].inject(0) do |memo, delta|
      memo + (@spec[y + delta[1]][x + delta[0]] == WALL ? 1 : 0)
    end > 2
  end
end
