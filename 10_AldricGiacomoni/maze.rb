class Maze
  require 'set'

  def initialize maze, args={}
    raise "No maze given, can't amaze!" if maze.nil?
    @options = {:start => "A", :destination => "B", :wall => "#", :open => " "}
    @options.merge! args
    @start, @end = nil, nil
    @pretty_map = maze
    @path = Set.new # One path to find them and in the darkness bind them.

    @maze = amaze maze
    raise "No beginning and/or end given!" if @start.nil? or @end.nil?
    @solvable = has_path_between @start, @end

  end

  def solvable?
    @solvable
  end

  def steps
    @path.size
  end

  def to_s
    @pretty_map
  end

  private

  def amaze maze
=begin
1. string => array of strings
2. hash of hashes per row and character, similar to a matrix
3. funny comment    
=end
    maze = maze.split("\n")
    maze.map! { |line| line.split(//)}
    new_maze = {}
    maze.each_with_index do |line, i|
      new_maze[i] ||= {}
      line.each_with_index do |point, j|
        new_maze[i][j] = {:value => point, :visited => false, :x => i, :y => j}
        # It is dark, and you are likely to be eaten by a grue.
        case point
          when @options[:start]
            raise "Two start points defined" unless @start.nil?
            @start = new_maze[i][j]
          when @options[:destination]
            raise "Two end points defined" unless @end.nil?
            @end = new_maze[i][j]
        end
      end
    end
    new_maze
  end

  def has_path_between start=@start, dest=@end
    return true if start == dest
    next_paths = get_paths_from start
    return false if next_paths.empty?

    # Wendy, give me the bat.
    next_paths.each do |point|
      point[:visited] = true
      if has_path_between point, dest
        @path << point
        return true
      end
    end
    return false
  end

  def get_paths_from point
    i = point[:x]
    j = point[:y]
    paths = [@maze[i-1][j], @maze[i][j-1], @maze[i+1][j], @maze[i][j+1]].shuffle
    # Let it not be said that the programmer chose anything. Randomness! Chaos!
    paths.delete_if do |point|
      point.nil? or point[:visited] or point[:value] == @options[:wall]
    end

  end

end