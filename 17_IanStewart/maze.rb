#BlueWizard is an old, nearsighted sorcerer, who leans hard on his cane. 
#He prefers to spawn (also nearsighted) copies of himself to explore the dungeon, rather than move himself.
class BlueWizard
  attr_accessor :steps
  
  def initialize(x,y,dungeon)
    @x, @y, @dungeon, @steps = x, y, dungeon, 0
  end
  
  def explore
    @@least_steps = nil
    cast_wizards [' ','B']
    @@least_steps ? true : false
  end
  
  def find_shortest_route
    cast_wizards [' ','B','@'] if explore
    @@least_steps ? @@least_steps : 0
  end
  
  protected
  
  def cast_wizards(valid_tiles)
    valid_moves(valid_tiles).each do |direction| 
      minion = self.clone
      minion.move direction
      unless @@least_steps && @@least_steps > minion.steps
        minion.underfoot == 'B' ? @@least_steps = minion.steps : minion.cast_wizards(valid_tiles)
      end
    end
  end
  
  def valid_moves(valid_tiles)
    allowed_moves = []
    allowed_moves << :up if (@y > 0) && (valid_tiles.include? @dungeon[@x][@y+1])
    allowed_moves << :down if (@y < @dungeon[0].length ) && (valid_tiles.include? @dungeon[@x][@y-1])
    allowed_moves << :left if (@x > 0) && (valid_tiles.include? @dungeon[@x-1][@y])
    allowed_moves << :right if (@x < @dungeon.length) && (valid_tiles.include? @dungeon[@x+1][@y])
    allowed_moves
  end

  def move direction
    case direction
    when :up then @y = @y + 1
    when :down then @y = @y - 1
    when :left then @x = @x - 1
    when :right then @x = @x + 1
    end
    @steps += 1
    @dungeon[@x][@y] = '@' unless underfoot == 'B' #'@' is a minion, standing in the maze
  end
  
  def underfoot
    @dungeon[@x][@y]
  end
  
end

#A maze on an X,Y coordinate system, with 0,0 on the bottom left corner
class Maze
  def initialize(maze)
   #Most of this line is just so we can work with [x,y] instead of [y,x]
    @maze = maze.split("\n").reverse.map {|maze_row| maze_row.split(//)}.transpose   
    @maze.each_with_index do |row,x|
      row.each_with_index do |maze_feature,y|
        @start = BlueWizard.new(x,y,@maze) if maze_feature == 'A'
        @finish = BlueWizard.new(x,y,@maze) if maze_feature == 'B'
      end
    end
  end
  
  def solvable?
    @start && @finish ? @start.explore : false
  end
  
  def steps
    @start && @finish ? @start.find_shortest_route : 0
  end
  
end