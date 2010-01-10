class Maze  
  
  attr_reader :maze
  
  HEIGHT = 13
  WIDTH = 38
    
  def initialize(maze_as_string)
    @maze = Array.new(HEIGHT)
    parse(maze_as_string)
    solve
  end
  
  def solvable?
    symbol_is_on_path?("A")
    symbol_is_on_path?("B")
  end
  
  def steps
    steps=0
    y=0
    while(y<HEIGHT) do
      x=0
      while(x<WIDTH) do
        if @maze[y][x] == " "
          steps+=1
        end
        x+=1
      end
      y+=1
    end
    unless steps==0
      steps+=1 # For the final step onto finish
    end
    return steps
  end
    
  def parse(maze_as_string)
    i=0
    maze_as_string.each_line do |line|  # replaced `each` to `each_line` by ashbb
      @maze[i] = line.chars.to_a
      i+=1
    end
  end
  
  def solve
    while(find_and_fill_dead_ends!=0) do
      find_and_fill_dead_ends
    end
  end
  
  def symbol_is_on_path?(symbol)
    location = find_symbol(symbol)
    return true if @maze[location[0]+1][location[1]] == " "
    return true if @maze[location[0]-1][location[1]] == " "
    return true if @maze[location[0]][location[1]+1] == " "
    return true if @maze[location[0]][location[1]-1] == " "
    return false
  end
  
  def find_symbol(symbol)
    symbol_position = []
    y=0
    while(y<HEIGHT) do
      x=0
      while(x<WIDTH) do
        symbol_position = [y, x] if @maze[y][x] == symbol
        x+=1
      end
      y+=1
    end
    return symbol_position
  end
  
  def find_and_fill_dead_ends
    y=0
    filled_spaces = 0
    HEIGHT.times do
      x=0
      WIDTH.times do
        filled_spaces+=1 if fill_if_dead_end?(y, x)
        x+=1
      end
      y+=1
    end
    return filled_spaces
  end
  
  def fill_if_dead_end?(y, x)
    if @maze[y][x] == " "
      
      wall_count = 0
      wall_count += 1 if @maze[y-1][x] == "#"
      wall_count += 1 if @maze[y+1][x] == "#"  
      wall_count += 1 if @maze[y][x+1] == "#"   
      wall_count += 1 if @maze[y][x-1] == "#"
      
      if wall_count >= 3
        @maze[y][x] = "#" 
        return true
      end
    end  
  end
  
  def to_s
    y=0
    HEIGHT.times do
      x=0
      WIDTH.times do
        print @maze[y][x]
        x+=1
      end
      y+=1
    end
  end
end