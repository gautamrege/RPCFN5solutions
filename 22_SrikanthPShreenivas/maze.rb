# RCPFN # 5 (Mazes) http://rubylearning.com/blog/2009/12/27/rpcfn-mazes-5/
# Solution by Srikanth P Shreenivas (srikanthps@yahoo.com)

class Maze

  def initialize(maze_definition)

    # Convert the string definition of maze in to a 2-dimensional array,
    maze = maze_definition.split("\n").map { |row| row.split(//) }


    # Iternate the 2-D Array to find the start point, stop point and list of
    # points that represent spaces in the maze
    @space_points = Array.new
    maze.each_with_index do |row_value, row_index|
      row_value.each_with_index do |column_value, column_index|
        @space_points[@space_points.length] = [row_index, column_index] if column_value.eql?(" ")
        @start_point = [row_index, column_index] if column_value.eql?("A")
        @stop_point = [row_index, column_index] if column_value.eql?("B")
      end
    end
  end

  def solvable?
    steps > 0
  end

  def steps
    steps_to_destination =  traverse(@start_point, @stop_point)
    steps_to_destination.size
  end

  # Traverses "from" point to "to" point, and returns array of points that needed
  # to be traversed to reach to "to" point.  It returns empty array if the "to"
  # point is not reachable from "from" point.
  def traverse (from, to, points_visited_so_far = [])
    
    return points_visited_so_far if from.eql?(to)

    # Select those adjacent points that that has not been already traversed
    # and that do not represent walls
    possible_steps = adjacent_traversible_points(from).select { |point| 
      (not points_visited_so_far.include?(point))
    }

    # For each possible step, take that step, and find out the list of points
    # that need to be traversed to reach "to" point. In case there were more
    # than one possible steps, pick the one that has smaller number of steps
    # to destination
    points_to_destination_from_here = []
    possible_steps.each do |point|
      traversal_result = traverse(point, to, points_visited_so_far + [point])
      if not traversal_result.empty?
        points_to_destination_from_here = traversal_result if 
              (points_to_destination_from_here.empty? or
              traversal_result.size < points_to_destination_from_here.size)
      end
    end
    
    return points_to_destination_from_here

  end

  # Finds the adjancent points that are either spaces or is the "stop"
  # (final destination) point
  def adjacent_traversible_points(point)

    left_point = [point[0] - 1, point[1]]
    right_point = [point[0] + 1, point[1]]
    top_point = [point[0], point[1] - 1]
    bottom_point = [point[0], point[1] + 1]

    [left_point, right_point, top_point, bottom_point].select do |n|
      (@space_points.include?(n) || n.eql?(@stop_point))
    end
  end

end