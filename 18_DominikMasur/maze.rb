# Idea was that all dead end fields are blocked.
class Position
  attr_accessor :x, :y
  def initialize x, y
    @x = x
    @y = y
  end
  def is? x, y
    @x == x && @y == y
  end
  def is_position? position
    @x == position.x && @y == position.y
  end
  def to_s
    "#{@x}, #{@y}"
  end
  def move direction
    case direction
      when "N" then @x -= 1
      when "S" then @x += 1
      when "W" then @y -= 1
      when "E" then @y += 1
    end
  end
end
class Maze
  def initialize old_maze
    @path_positions = []
    transform_maze old_maze
    @current_position = @start.clone
  end
  def solvable?
    return steps > 0
  end
  def steps
    directions = free_directions @current_position
    path = []
    while !@current_position.is_position?(@end) && !directions.empty?
      # dead end check
      @maze[@current_position.x][@current_position.y] = '#' if directions.size == 1
      # Make Move
      last_move = calc_next_step directions, last_move
      # Create right Path
      if path.last == opposite_direction(last_move)
        path.pop 
      else
        path << last_move
      end
      @current_position.move last_move
      # Check new directions
      directions = free_directions @current_position
    end
    return 0 if !@current_position.is_position?(@end)
    return path.size
  end
  def calc_next_step directions, last_direction
    if last_direction && directions.size > 1
      directions.delete opposite_direction(last_direction)
    end
    return directions.last
  end
  def opposite_direction direction
    return case direction
      when "N" then "S"
      when "S" then "N"
      when "E" then "W"
      when "W" then "E"
    end
  end
  # Printing
  def to_s
    string = ""
    @maze.each_with_index do |line,index|
      line.each_with_index do |char,index2|
        if @current_position && @current_position.is?(index, index2)
          string << "C"
        elsif @start.is? index, index2
          string << "A"
        elsif @end.is? index, index2
          string << "B"
        else
          string << char
        end
      end
      string << "\n"
    end
    return string
  end
  # Free directions to go
  def free_directions position
    directions = []
    if position.x-1 >= 0 && @maze[position.x-1][position.y] == " "
      directions << "N"
    end
    if position.x+1 >= 0 && @maze[position.x+1][position.y] == " "
      directions << "S"
    end
    if position.y-1 >= 0 && @maze[position.x][position.y-1] == " "
      directions << "W"
    end
    if position.y+1 >= 0 && @maze[position.x][position.y+1] == " "
      directions << "E"
    end
    return directions
  end
  # Transforming Maze into Array
  def transform_maze old_maze
    @maze = []
    old_maze.each_line do |line|
      new_line = ""
      line.each_char do |char|
        case char
        when "\n" then 
        when 'A' then
          @start = Position.new @maze.size, new_line.size
          new_line += " "
        when 'B' then
          @end = Position.new @maze.size, new_line.size
          new_line += " "
        else
          new_line += char
        end
      end
      @maze << new_line.split("")
    end
    return @maze
  end
end