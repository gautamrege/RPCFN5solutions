WALL = 'WALL' # constant denoting a WALL (point in the maze that we can't move past)
SPACE = 'SPACE' # constant denoting a point that can be traversed

# The Point class represents a point @ x, y in the maze.
# It's value is either 'WALL' ('#' in the original string)
# or 'SPACE' (' ' in the original string).
# NOTE: The end-point (B) is also given the value SPACE
# because it is legal to move to that point.
class Point
  attr_accessor :x, :y, :val
  def initialize(x, y, val)
    self.x = x
    self.y = y
    self.val = val
  end

  # For Hash lookup and equality comparisons, two points
  # are the same if their x and y coordinates are the same
  def eql?(other)
    (self.x == other.x) && (self.y == other.y)
  end
  # The hash of two points should also computer to the same value
  def hash
    "#{x},#{y}".hash
  end
  # Print string for debugging purposes
  def to_s
    "(#{x},#{y})"
  end
end

# A segments is given a point to start from and from there, it "crawsl"
# forward, one point at a time. As long as there is only one possibility
# of going forward (even if the segment has to turn 90 degrees), the
# segment continues to crawl and accumulate a list of points. It will
# end up hitting a 'WALL' or succeed in reaching the end-point B. However,
# if in the process of crawling, it comes across 2 or more open spaces, it
# creates 2 ore more sub-segments (starting with those open-spaces).These
# sub-segments then keep crawling until they hit a WALL or the end-point,
# or they create sub-segments of their own, and the process continues...

# Note: In order for multiple segments (in a maze) to crawl without tripping
# over each other, or "turning back", a common data-structure of "visited"
# points is kept (in the Maze object which is a common object to all the 
# segments). Each time a segment crawls forward to a point, it adds that
# point to the list of visited points.
class Segment
  # st_pt = the initial point from which the Segment will start crawling
  # maze is the parent maze to which this segment belongs
  # points is an array (first element = st_pt) of points that are crawled
  # segments = sub_segments if any
  attr_accessor :st_pt, :maze, :points, :segments
  def initialize(st_pt, maze)
    self.st_pt = st_pt
    self.maze = maze
    self.points = Array.new
    # The array of points starts off with st_pt
    self.points << st_pt
    # No sub-segments in the beginning
    self.segments = Array.new
  end

  # Try to crawl one point forward from where the segment is currently at
  # (from_pt)
  def crawl(from_pt)
    # We've reached the end-point (success - so return)
    return if from_pt == self.maze.end_pt
    # Else, tell the maze that this point was just visited
    self.maze.visited(from_pt)
    # Ask the maze for adjacent open points next to from_pt
    open_spaces = self.maze.open_spaces(from_pt)
    case (open_spaces.size)
    when 0 # No open spaces - we've hit a WALL
    when 1 #Exactly one open spot - continue crawling after
           # updating the 'points' array
      next_pt = open_spaces.first
      self.points << next_pt
      # continue crawling unless we just hit the end-point
      self.crawl(next_pt) unless next_pt == self.maze.end_pt
    else
      # multiple open spaces (points). Create sub segments for each
      # open point with that point as the starting point.
      open_spaces.each do |pt|
        s = Segment.new(pt, self.maze)
        self.segments << s
        s.crawl(pt)
      end
    end
  end

  # How many steps in this segment?
  def steps
    # return -1 if this segment isn't going to succeed in reaching the end-point
    return -1 unless self.solvable?
    # otherwise, go ask each sub-segment for their count (if there are any
    # sub-segments, that is)
    sub_counts = self.segments.collect { |e| e.steps  }
    # y <=> x means largest number is firt element after sorting. Since non
    # solvable segments return -1, the first element will now be a real 
    # number of steps from a solvable sub-segment
    sub_counts.sort! { |x, y|  y <=> x }
    # just in case there are multiple segments that can succeed, choose the one
    # with the smallest count
    smallest_subcount = sub_counts[0] == nil ? 0 : sub_counts[0]
    # add our own points array size to the sub-segment count
    self.points.size + smallest_subcount
  end

  # Can this segment or one of it's sub-segments reach the end-point?
  def solvable?
    # Either the points array is already at the end-point or if there are
    # sub-segments, ask them if they are solvable
    (self.points.last == self.maze.end_pt) || (self.segments.detect { |s| s.solvable? })
  end
end


# Maze class has a collection of points with values of 'WALL' or 'SPACE', based on
# the definition string that is passed into the constructor
class Maze
  # st_pt will hold the point with value 'A'
  # end_pt will hold the point with value 'B'
  # width, height = maze dimensions
  # initial_segments = 0 or more segments created out of the empty spaces adjacent
  # to the st_pt. Things are set in motion by asking these initial segments to
  # start crawling
  attr_accessor :width, :height, :points, :st_pt, :end_pt, :initial_segments

  # construct the maze
  def initialize(maze_def)
    lines = maze_def.split(/\n/) # first, break up the lines
    self.height = lines.size
    self.width = lines.first.size
    self.points = Hash.new
    (0 .. self.height-1).each do |y|
      chars = lines[y].split(//) # break each line into a char
      (0 .. self.width-1).each do |x|
        case (chars[x])
        when 'A' # record st_pt
          pt = self.st_pt = Point.new(x, y, WALL)
        when 'B' # record end_point, but also put it's value as SPACE
                 # meaning we can traverse to it.
          pt = self.end_pt = Point.new(x, y, SPACE)
        when '#' # this is a wall. dead-end
          pt = Point.new(x, y, WALL)
        else ' ' # there is still hope we might reach the end-point
          pt = Point.new(x, y, SPACE)
        end
        self.points["#{pt}"] = pt # update the points hash
      end
    end
    @visited = Array.new
    @visited << self.st_pt # only the st_pt is initially considered
    # to have been visited, before the segments start to crawl
    open_spaces = self.open_spaces(self.st_pt)
    self.initial_segments = Array.new
    # construct an initial_segment from each open space around
    # the st_pt
    open_spaces.each do |pt|
      s = Segment.new(pt, self)
      self.initial_segments << s
      s.crawl(pt) # ask the segment to crawl - see who, if any, wins
    end
  end

  # record that a point has been visited by one of the crawling segments
  def visited(pt)
    @visited << pt
  end

  # How many steps to solve the maze
  def steps
    counts = Array.new
    counts << 0 # if no solvable segment, then answer 0
                # (expected by this quiz problem statement)
    self.initial_segments.each { |s| counts << s.steps}
    # since non-solvable segments answer -1, we sort so that the
    # largest number is the first element (y <=> x). That way it is
    # either 0 (non solvable) or the count returned by one of the
    # solvable segments
    counts.sort! {|x,y| y <=> x }
    counts[0]
  end

  # All the maze can do is ask the initial_segments if they are solvable
  def solvable?
    self.initial_segments.detect { |s| s.solvable? } ? true : false
  end

  # Segments query the Maze (which has the definition of open and walled
  # points), to find out what open points there are, adjacent to a given point.
  # The maze only answers open points that have not yet been visited, so
  # segments don't accidentally crawl backwards
  def open_spaces(pt)
    spaces = Array.new
    pts = Array.new
    # 4 adjacent points
    pts << left_val(pt) << right_val(pt) << up_val(pt) << down_val(pt)
    # do we have any that are SPACE and not yet visited?
    pts.each { |pt| spaces << pt if (pt.val == SPACE && !@visited.include?(pt)) }
    spaces
  end

  # value of the point to the left of the given point
  def left_val(pt)
    self.points["#{Point.new(pt.x-1,pt.y, nil)}"]
  end
  # value of the point to the right of the given point
  def right_val(pt)
    self.points["#{Point.new(pt.x + 1,pt.y, nil)}"]
  end
  # value of the point to the top of the given point
  def up_val(pt)
    self.points["#{Point.new(pt.x, pt.y-1, nil)}"]
  end
  # value of the point to the bottom of the given point
  def down_val(pt)
    self.points["#{Point.new(pt.x, pt.y+1, nil)}"]
  end

end
