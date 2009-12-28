# Curiously, if you type 1.0 / 0.0 into the irb prompt, ruby returns
# Infinity; however if you type in Infinity directly, ruby complains
# about an uninitialized constant. Define it here.
Infinity = 1.0 / 0.0

# Finding the least number of steps one would have to take within the
# maze to get from point A to point B can be interpreted as a problem
# of finding the distance between 2 vertices in a graph.  We abstract
# it in a class Graph.  A graph consists of an array of vertices, and
# for each vertex an array of vertices adjacent to it.
class Graph
  # `vertices' is an array, `adjacent' is a hash of arrays.
  def initialize(vertices, adjacent)
    @vertices, @adjacent = vertices, adjacent
  end
  # Dijkstra's algorithm for finding the distance from a given vertex
  # to every other vertex.  Returns a hash of distances.
  #
  # See http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm.  
  def distances_from(source)
    # `d' is a hash of distances to each vertex from the source.
    d = {}
    # Initially, set the distance to `Infinity' for each vertex...
    @vertices.each {|vertex| d[vertex] = Infinity }
    # ... except that the distance from the source to itself is 0.
    d[source] = 0
    # `unvisited' maintains an array of unvisited vertices.  Initially
    # it contains all the vertices of the graph.
    unvisited = @vertices
    # The main loop.
    until unvisited.empty?
      # Choose a vertex with the smallest distance to the source.
      current = unvisited.min { |v1, v2| d[v1] <=> d[v2] }
      # If the distance from this vertex to the source is Infinity,
      # then all remaining unvisited vertices are inaccessible from
      # the source, hence return.
      return d if d[current] == Infinity
      # Otherwise, mark the current vertex as visited.
      unvisited.delete(current)
      # Relax each vertex adjacent to the current vertex.
      @adjacent[current].each do |vertex|
        if d[vertex] > d[current]+1 then d[vertex] = d[current]+1 end
      end
    end
    # Finally, return `d'.
    d
  end
end

# Our Maze class is a subclass of Graph: @vertices is an array of all
# the cells in the maze (which we enumerate first), and for each cell
# c the value of @adjacent[c] is an array of (<= 4) adjacent cells.
class Maze < Graph
  # Parse a maze (given as a string) into a graph.
  def initialize(string)
    @vertices, @adjacent, index = [], {}, 0
    # Split the given string into separate lines.  Map over each char
    # in each line, enumerate all the chars different from #, collect
    # their indices into the @vertices array, and save the indices of
    # the points A and B.
    grid = string.split("\n").map do |line|      
      line.chars.map do |char|
        if char == "#" then "#"
        else
          index += 1
          @vertices << index
          @a = index if char == "A"
          @b = index if char == "B"
          index
        end
      end
    end
    # `grid' is an array of arrays, which we visualize as a matrix.
    # Each element of it is either a number, which denotes a cell,
    # or the character "#", which denotes a wall.  Iterate over all
    # the cells and for each cell find the cells adjacent to it.
    #
    # We assume that the maze is rectangular and is surrounded by a
    # solid wall.  Otherwise more careful analysis of edge cases is
    # necessary.
    grid.each_with_index do |line, row|
      line.each_with_index do |cell, col|
        unless cell == "#"
          @adjacent[cell] = [grid[row-1][col],
                             grid[row][col-1],
                             grid[row+1][col],
                             grid[row][col+1]].reject { |cell| cell == "#" }
        end
      end
    end
  end
  def solvable?
    # The maze is solvable if the distance from A to B is finite.
    distances_from(@a)[@b] < Infinity
  end
  def steps
    # Slightly inconsistently, according to the test suite Maze#steps
    # must return 0 if the maze is unsolvable.
    d = distances_from(@a)[@b]
    if d < Infinity then d else 0 end
  end
end
