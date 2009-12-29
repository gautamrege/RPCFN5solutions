class Maze
  
  # Will solve text mazes for food.
  #
  # This solution will find the most direct route form point A to point B.
  #
  # For grins, this maze will also display the solution to the maze with Maze#show_solution... 
  #
  #   #####################################
  #   # #    .................#     #     #
  #   # ### #.# # ###########.### # ##### #
  #   # #   #.#   #   #   #  ...  #       #
  #   # # ###A##### # # # # ###.###########
  #   #   #   #     #   # # #  ...        #
  #   ####### # ### ####### # ###.####### #
  #   #       # #   #       # #  .........#
  #   # ####### # # # ####### # ##### # #.#
  #   #       # # # #   #       #   # # #.#
  #   # ##### # # ##### ######### # ### #.#
  #   #     #   #                 #     #B#
  #   #####################################
  
  
  def initialize(maze)
    # Convert maze string into an array for traversing
    create_maze_array(maze)
    
    # Get the height and width of the array, minus one for array index comparison
    @width = maze.index("\n") - 1
    @height = @maze_array.size - 1
    # Setting the value of the target to be the height * width of the maze.
    # This target will decrement by one for each adjacent space, allowing us to
    # calculate the steps to the endpoint and also map the solution.
    @b_value = @height * @width
    
    # Creates a hash of all the spaces in the map. 
    # Hash keys are the address (row, column) of the space.
    map_spaces(@maze_array)
    
    # Stores the location of the start points and end points
    @end = @spaces_hash.index("B")
    @start = @spaces_hash.index("A")
    
    # Starting from the end point, create a ToDo array of adjacent spaces
    # to assign decrementing values.
    create_todo_array(@spaces_hash)
    
    until @todo_list.empty?
      # Assign decrementing values to adjacent spaces
      fill_maze(@todo_list)
    end
  end
  
  def solvable?
    @spaces_hash[@start].to_i > 0
  end
  
  def steps
    if solvable?
      @spaces_hash[@end] - @spaces_hash[@start]
    else
      return 0
    end
  end
  
  def create_maze_array(maze)
    @maze_array = maze.split("\n")
    @maze_array.each_with_index do |s, i|
      @maze_array[i] = s.split(//)
    end
  end
  
  def map_spaces(maze_array)
    @spaces_hash = Hash.new
    maze_array.each_with_index do |array, row|
      array.each_with_index do |element, column|
        unless element == "#"
          key = Array[row, column]
          @spaces_hash[key] = element
        end 
      end
    end
  end
  
  def create_todo_array(spaces_hash)
    @todo_list = []
    # We're starting from the endpoint 'B'
    start = spaces_hash.index("B")
    spaces_hash[start] = @b_value
    @todo_list << start
  end
  
  def fill_maze(todo_list)
    todo_list.each do |address|
      # Retrieve the current value of the space in the ToDo list, decrement by one.
      value = get_value(address) - 1
      get_adjacent_addresses(address)
      fill_adjacent_addresses(address, value)
      # Remove this element from the to-do list
      @todo_list.delete(address)
    end
  end
  
  def get_adjacent_addresses(address)
    up     = Array[ address[0] + 1, address[1] ]
    down   = Array[ address[0] - 1, address[1] ]
    left   = Array[ address[0], address[1] - 1 ]
    right  = Array[ address[0], address[1] + 1 ]
    @neighbors = Array[ up, down, left, right ]
  end
  
  def fill_adjacent_addresses(address, value)
    row = address[0]
    column = address = [1]
    @neighbors.each do |addr|
      apply_value_to_space(addr, value)
    end
  end
  
  def get_value(address)
    # Gets the value of the current location. 
    # If the current location is 'B', the value is @target_value (the max value for the maze).
    @spaces_hash[address] == "B" ? @b_value : @spaces_hash[address]
  end
  
  def apply_value_to_space(address, value)
    # Check if location is valid
    if @spaces_hash.has_key?(address)
      # Make sure we don't over-write a larger value
      if @spaces_hash[address].to_i < value
        @spaces_hash[address] = value
        # Add this location to the ToDo list
        @todo_list << address
      end
    end
  end
  
  def show_solution
    if solvable?
      create_solution
      @spaces_hash.each do |k, v|
        if v == "."
          row = k[0]
          column = k[1]
          @maze_array[row][column] = v
        end
      end
      solution_string = ""
      @maze_array.each do |array|
        solution_string << array.to_s
        solution_string << "\n"
      end
      puts solution_string
    else
      return "No solution to show, maze is unsolvable."
    end
  end
  
  def solution_step(address)
    @active_value = @spaces_hash[address]
    @active_address = address
    @spaces_hash[address] = "."
  end
  
  def create_solution
    starting_value = @spaces_hash[@start]
    @active_address = @start
    @active_value = @spaces_hash[@start]
    
    @spaces_hash[@start] = "A"
    @spaces_hash[@end] = "B"
    
    while @active_value < @b_value - 1
      active_row = @active_address[0]
      active_column = @active_address[1]
      get_adjacent_addresses(@active_address)
      @neighbors.each do |address|
        if @spaces_hash.has_key?(address) && @spaces_hash[address].to_i > @active_value
          solution_step(address)
        end
      end
    end
    
  end
  
end