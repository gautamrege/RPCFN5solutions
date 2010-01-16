class Maze
  attr_reader :maze_array
  def initialize(maze)
    @maze_array = maze.split("\n") #create array of lines of the string
    @maze_array.map! { |line| line.chars.to_a } #converts array to 2-d array of characters in maze
    raise ArgumentError, "All lines must be of the same length", caller if !@maze_array.all? {|line| line.length == @maze_array[0].length}
    @height = @maze_array.length #store the height of the maze in an instance variable
    @width = @maze_array[0].length #store the length of the maze in an instance variable (assumes each line is the same length - should really test for this if being thorough)
    @maze_array.each_with_index do |line, index1| #search array to find start and end of maze 
      line.each_with_index do |char, index2|
        @start_row, @start_col = index1, index2 if char == "A" #start is denoted by A
        @end_row, @end_col = index1, index2 if char == "B" #end is denoted by B
      end
    end
    raise ArgumentError, "Maze must contain a start point \"A\"", caller if !@start_row
    raise ArgumentError, "Maze must contain an end point \"B\"", caller if !@end_row
  end

  def solvable?
    @solvable = false #This will be set to true if map is solvable
    map = Marshal.load(Marshal.dump(@maze_array)) #Create a working duplicate of @maze_array
    map.each { |line| line.map! { |char| [char, false] }} #Add a 3rd dimension to array to account for locations having been visited already
    explore(map, @start_row, @start_col) #explore function to determine if map is solvable
    @solvable
  end

  def steps
    return 0 unless solvable? #If not solvable, don't bother trying!
    map = Marshal.load(Marshal.dump(@maze_array)) #Create a working duplicate of @maze_array
    node_list = []
    #Step 1. Create an array of all coordinates on the map that will function as nodes for shortest path search (node_list)
    #A coordinate is a node if it contains "A" or "B", or is a " " that has at least 2 adjacent spaces " " on non-opposite sides
    #i.e. is either a corner or an intersection
    #Can just check for corners as all intersections will test positive with the corner test used here.
    map.each_with_index do |line,index1|
      line.each_with_index do |char,index2|
        node = false
        dirs = {up: false, down: false, left: false, right: false} #won't work with Ruby 1.8
        if char == " "
          up, down, left, right = up (map,index1,index2), down (map,index1,index2), left (map,index1,index2), right (map,index1,index2)
          dirs[:up] = true if up[0]==" " or up[0]=="A" or up[0]=="B" if up
          dirs[:down] = true if down[0]==" " or down[0]=="A" or down[0]=="B" if down
          dirs[:left] = true if left[0]==" " or left[0]=="A" or left[0]=="B" if left
          dirs[:right] = true if right[0]==" " or right[0]=="A" or right[0]=="B" if right
          node = true if (dirs[:up] and dirs[:left]) or (dirs[:up] and dirs[:right]) or (dirs[:down] and dirs[:left]) or (dirs[:down] and dirs[:right])
        end
        node_list << [index1, index2] if char == "A" or char == "B" or node #Add co-ords of current position to node_list if it is indeed a node
      end
    end
    #Step 2, create a hash linking each node to all other nodes that can be directly reached from that node with the distance between them
    search_list = {}
    node_list.each do |source|
      potentials = {up: {}, down: {}, left: {}, right: {}}
      #First find all nodes in the same row or column as current (source) node and store them in potentials hash (key is direction of nodes, value is hash of nodes/distances in that direction)
      node_list.each do |target|
        if distance = reachable?(source,target) #first, determine if target node is reachable from source node and collect these in potentials hash with direction as key
          potentials[:up][target] = distance if source[0]>target[0]
          potentials[:down][target] = distance if source[0]<target[0]
          potentials[:left][target] = distance if source[1]>target[1]
          potentials[:right][target] = distance if source[1]<target[1]
        end
      end
        #next find only the nearest target node in each direction
      short_list = []
      potentials.each do |direction, nodes|
        sorted_nodes = []
        sorted_nodes = nodes.sort{|a,b| b[0][0] <=> a[0][0]} if direction == :up && nodes != {}
        sorted_nodes = nodes.sort{|a,b| a[0][0] <=> b[0][0]} if direction == :down && nodes != {}
        sorted_nodes = nodes.sort{|a,b| b[0][1] <=> a[0][1]} if direction == :left && nodes != {}
        sorted_nodes = nodes.sort{|a,b| a[0][1] <=> b[0][1]} if direction == :right && nodes != {}
        #potential nodes in each direction are sorted so nearest node is in position 0 of array
        #If there is a node in this direction, add it to the short_list array
        short_list << sorted_nodes[0] if sorted_nodes != []
      end
      #short_list is now an array of hashes, each has containing the node co-ordinates in an array as the key, and the distance to that node as the value
      #Now, add these to the search_list hash for the current source node
      short_list.each do |value|
        if search_list.has_key?(source)
          search_list[source][value[0]] = value[1]
        else
          search_list[source] = {value[0] => value[1]}
        end
      end
    end
    #search_list now contains a hash containing all nodes in map as keys and a hash of all nodes reachable
    #from that node, along with the distance to that node, as the hash value
    #Step 3, determine length of shortest path between A and B using Dijkstra algorithm
    #Implementation heavily borrowed from RPCFN#3 answer provided by Valério Farias
    distance = {}
    node_list.each {|x| distance[x] = 1.0/0}
    distance[[@start_row,@start_col]] = 0
    while (!node_list.empty?)
      smallest = nil
      node_list.each do |min|
        smallest = min if (!smallest) or (distance[min] and distance[min] < distance[smallest])
      end
      break if distance[smallest] == 1.0/0
      break if smallest[0] == @end_row && smallest[1] == @end_col #Shortest path to "B" has been found so can stop execution
      node_list -= [smallest]
      search_list[smallest].each do |node,dist|
        alt = distance[smallest] + dist
        distance[node] = alt if alt < distance[node]
      end
    end
    distance[[@end_row,@end_col]]
  end

  #protected

  def explore(map,row,col)
    #explore recursively searches through map. Given a starting row/col, will sequentially look in each direction.
    #If the map square in that direction is a space, explore will call itself to continue exploration from the new map square
    #Map if marked solvable if the end square is encountered.
    #This method could possibly be a little bit DRYer
    
    #look left
      if left = left(map,row,col) #Get character in map to left up current row/col (evaluates false if off the map)
        if left[0] == " " && left[1] == false #Test if character to the left is a previously unvisited space
          map[row][col-1][1] = true  #If so, mark that space as visited 
          explore(map,row,col-1)  #and iteratively explore that space
        end
        @solvable = true if left[0] == "B" #Declare the map solvable if the space to the left of the current row/col is the end character
      end
    #look right
      if right = right(map,row,col) 
        if right[0] == " " && right[1] == false
          map[row][col+1][1] = true
          explore(map,row,col+1)
        end
        @solvable = true if right[0] == "B"
      end
    #look up 
      if up = up(map,row,col) 
        if up[0] == " " && up[1] == false
          map[row-1][col][1] = true
          explore(map,row-1,col)
        end
        @solvable = true if up[0] == "B"
      end
    #look down
      if down = down(map,row,col) 
        if down[0] == " " && down[1] == false
          map[row+1][col][1] = true
          explore(map,row+1,col)
        end
        @solvable = true if down[0] == "B"
      end
  end     
    
  def up(map,row,col) #returns the 3rd dimension of array for map location up from row and col
    return false if row == 0 #at top of map so nothing up
    map[row-1][col]
  end
  
  def down(map,row,col)
    return false if row == @height-1
    map[row+1][col]
  end
  
  def left(map,row,col)
    return false if col == 0
    map[row][col-1]
  end
  
  def right(map,row,col)
    return false if col == @width-1
    map[row][col+1]
  end
  
  def reachable?(source,target) #Check if there is an uninterrupted line between 2 points and return distance between them
    if source[0] == target[0] #Source and target are in the same row
      distance = (source[1]-target[1]).abs
      return 1 if distance == 1 #Source and target are adjacent so must be connected
      flag = true
      source[1] < target[1] ? (s, t = source[1], target[1]) : (s, t = target[1], source[1])
      (s+1...t).to_a.each { |col| flag = false if @maze_array[source[0]][col] == "#" } #Unset flag if any point on the path between source and target is blocked
      return (flag ? distance : false)
    end
    if source[1] == target[1] #Source and target are in the same column
      distance = (source[0]-target[0]).abs
      return 1 if distance == 1 #Source and target are adjacent so must be connected
      flag = true
      source[0] < target[0] ? (s, t = source[0], target[0]) : (s, t = target[0], source[0])
      (s+1...t).to_a.each { |row| flag = false if @maze_array[row][source[1]] == "#" } #Unset flag if any point on the path between source and target is blocked
      return (flag ? distance : false)
    end
    false #Source and target are in different rows and columns so return false
  end
  
end