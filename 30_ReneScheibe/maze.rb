class Maze
  def initialize maze_as_string
    @input_string = maze_as_string
    @input_string.extend(MazeString)
    @waypoints = @input_string.extract_waypoints
  end

  def solvable?
    steps != 0
  end

  def steps
    return 0 unless valid?

    waypoints = {@waypoints.start_position => 0}

    waypoints.each do |current_waypoint, path_length|
      return path_length if current_waypoint == @waypoints.end_position
      new_waypoints = spot_new_waypoints(current_waypoint, waypoints)
      new_waypoints.each{ |waypoint| waypoints[waypoint] = path_length + 1 }
    end

    0
  end

  protected
  def valid?
    @input_string.valid?
  end

  def spot_new_waypoints current_waypoint, visited_waypoints
    row, col = current_waypoint
    candidate_waypoints = [[row-1, col], [row+1, col], [row, col-1], [row, col+1]]
    candidate_waypoints.select{ |waypoint| @waypoints[waypoint] && !visited_waypoints[waypoint] }
  end
end

module MazeString
  SYMBOLS = {:wall => '#', :space => ' ', :start => 'A', :end => 'B'}

  def valid?
    has_valid_symbols? and has_one_start? and has_one_end?
  end

  def extract_waypoints
    waypoints = WaypointStore.new
    self.split($/).each_with_index do |line, row|
      line.split('').each_with_index do |char, col|
        waypoints[[row, col]] = char unless char == SYMBOLS[:wall]
      end
    end
    waypoints
  end

  protected
  def has_valid_symbols?
    (self =~ /^[#{SYMBOLS.values.join}]*$/) != nil
  end

  def has_one_start?
    self.count(SYMBOLS[:start]) == 1
  end

  def has_one_end?
    self.count(SYMBOLS[:end]) == 1
  end
end

class WaypointStore < Hash
  def start_position
    @start_position ||= invert[MazeString::SYMBOLS[:start]]
  end

  def end_position
    @end_position ||= invert[MazeString::SYMBOLS[:end]]
  end
end
