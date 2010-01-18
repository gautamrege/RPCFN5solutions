=begin
Title:               Ruby Challenge #5
Program Description: Maze Solver
Submitted By:        Jean-Christophe Cyr
=end

class Maze
  MAZE_START = 'A'
  MAZE_END = 'B'
  NAVIGABLE_SPACE = ' '

  Coordinates = Struct.new("Coordinates", :col, :row)

  def initialize(maze)
    @maze = []
    maze.each_line { | s |
      current_line = s.split('')
      @maze << current_line
      start_column = current_line.index(MAZE_START)
      @start_cell = Coordinates.new(start_column, @maze.size-1) unless start_column.nil?
      end_column = current_line.index(MAZE_END)
      @end_cell = Coordinates.new(end_column, @maze.size-1) unless end_column.nil?
    }
  end

  #
  # Returns true if the maze can be solved
  #
  def solvable?
    find_solution > 0
  end

  #
  # Find the minimum number of steps to solve the maze
  #
  def steps
    find_solution
  end

  private

  #
  # Find the number of steps using shortest path algorithm
  #
  def find_solution
    open = [{:cell => @start_cell, :parent => nil, :distance => 0}]
    closed = []

    while !open.empty?
      # Find the lowest movement cost
      current_node = open.min{ |a,b| a[:distance] <=> b[:distance]}

      # Check if we reached the end cell
      if is_end?(current_node[:cell])
        return current_node[:distance]
      end

      # Find immediate neighbors
      current_neighbors = find_neighbors(current_node[:cell])
      current_neighbors.each { | neighbor |
        if closed.find { | node | node[:cell].eql?(neighbor[:cell])}.nil?
          # Find if the cell is already in the open list
          existing_open = open.find { |node | node[:cell].eql?(neighbor[:cell])}
          if existing_open
            # Find the shorter distance to the cell
            current_distance = existing_open[:distance]
            new_distance = current_node[:distance] + neighbor[:distance]
            existing_opened[:distance] = new_distance if current_distance > new_distance
          else
            # Add the new visited cell to the open list
            neighbor[:distance] = neighbor[:distance] + current_node[:distance]
            open << neighbor
          end
        end
      }
      closed << current_node
      open.delete(current_node)
    end
    0
  end

  #
  # Find ajacent intersections of the cell
  #
  def find_neighbors(cell)
    neighbors = []
    neighbors << find_top_path(cell)
    neighbors << find_right_path(cell)
    neighbors << find_bottom_path(cell)
    neighbors << find_left_path(cell)

    # Return all the neighbors with the parent cell and the distance between them
    neighbors.compact.collect { |current_cell| {:cell => current_cell, :parent => cell, :distance => find_distance_between(current_cell, cell)}}
  end

  #
  # Finds the intersection at the top of the cell
  #
  def find_top_path(cell)
    find_path(cell) { | cell | top_cell(cell) }
  end

  #
  # Finds the intersection at the right of the cell
  #
  def find_right_path(cell)
    find_path(cell) { | cell | right_cell(cell) }
  end

  #
  # Finds the intersection at the bottom of the cell
  #
  def find_bottom_path(cell)
    find_path(cell) { | cell | bottom_cell(cell) }
  end

  #
  # Finds the intersectionat the left of the cell
  #
  def find_left_path(cell)
    find_path(cell) { | cell | left_cell(cell) }
  end

  #
  # Finds the intersection ajacent to the cell
  #
  def find_path(cell, &block)
    current_cell = cell
    begin
      current_cell = yield(current_cell)
      return current_cell if is_intersection?(current_cell)
    end while is_navigable_space?(current_cell)
    nil
  end

  #
  # Returns the distance between two cells that are
  # on the same row or same column
  #
  def find_distance_between(cell1, cell2)
    if cell1.nil? || cell2.nil?
      return 0
    end

    if cell1.col == cell2.col || cell1.row == cell2.row
      return ((cell1.row - cell2.row) + (cell1.col - cell2.col)).abs
    end

    0
  end

  #
  # Returns true if the cell is the start cell
  #
  def is_start?(cell)
    @start_cell.eql?(cell)
  end

  #
  # Returns true if the cell is the end cell
  #
  def is_end?(cell)
    @end_cell.eql?(cell)
  end

  #
  # Returns true if the cell is navigable
  #
  def is_navigable_space?(cell)
    return false if cell.nil?
    return false unless is_valid_cell?(cell)
    value = @maze[cell.row][cell.col]
    NAVIGABLE_SPACE.eql?(value) || is_start?(cell) || is_end?(cell)
  end

  #
  # Returns true if the cell is an intersection, the start cell or the end cell
  #
  def is_intersection?(cell)
    return false unless is_navigable_space?(cell)

    return true if is_start?(cell) || is_end?(cell)

    navigable_top_cell = is_navigable_space?(top_cell(cell))
    navigable_bottom_cell = is_navigable_space?(bottom_cell(cell))
    navigable_left_cell = is_navigable_space?(left_cell(cell))
    navigable_right_cell = is_navigable_space?(right_cell(cell))

    if ((navigable_top_cell || navigable_bottom_cell) && (navigable_left_cell || navigable_right_cell))
      return true
    end

    return false
  end

  #
  # Get the cell at the top
  #
  def top_cell(cell)
    get_next_cell(cell) { | cell | Coordinates.new(cell.col, cell.row-1)}
  end

  #
  # Get the cell at the bottom
  #
  def bottom_cell(cell)
    get_next_cell(cell) { | cell | Coordinates.new(cell.col, cell.row+1)}
  end

  #
  # Get the cell at the left
  #
  def left_cell(cell)
    get_next_cell(cell) { | cell | Coordinates.new(cell.col-1, cell.row)}
  end

  #
  # Get the cell at the right
  #
  def right_cell(cell)
    get_next_cell(cell) { | cell | Coordinates.new(cell.col+1, cell.row)}
  end

  #
  # Get a cell that is ajacent to a cell
  #
  def get_next_cell(cell, &block)
    return nil if cell.nil?

    next_cell = yield(cell)
    return next_cell if is_valid_cell?(next_cell)
    nil
  end

  #
  # Check is a given cell is out of bounds
  #
  def is_valid_cell?(cell)
    if cell.nil?
      return false
    end

    if cell.col < 0 || cell.row < 0
      return false
    end

    if cell.row < @maze.size && cell.col < @maze[0].size
      return true
    end

    false
  end
end
