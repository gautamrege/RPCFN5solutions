=begin

 The solution is contained in 2 files
  1. maze.rb - the Maze class (this file. It in turn relies heavily on 2.
  2. RPCFN3_classes.rb - Contains all class definitions for the node network

     RPCFN3_classes were written in my doomed attempt to solve RPCFN3.
     I failed that one, but only by a (stupid) hairs breadth.
     So here, i use the same framework. A maze is just another network or map,
     a collection of nodes/points connected by links/paths/edges.
     I did intend at the time of RPCFN3 to develop some reusable code.
     This challenge has given me a use case to demostrate reuse.

= SYNOPSIS =======================================================
  A point/node is added to the map for each space character on the
  input maze. These are all the locations to which we can navigate.
  The (#) maze wall/brick nodes are just discarded.
  Each space node can have up to 4 links/edges that lead to an adjacent
  space node positioned either to the immediate left or right, or
  immediately above or below it.

  By using the RPCFN3 classes, the challenge is limited to priming
  the network or map with the input maze.
  a) Load all the space nodes from the input file. They are identified
     by their line and character numbers, starting at 0_0 and ending
     at 12_36. At this point the nodes are orphans, no links.
  b) Visit each node and add links (i call them paths) to all
     adjacent nodes.
  All of a) and b) is done when a maze is instantiated.

  The rest of it is in RPCFN3_classes built previously.

  c) Get all possible routes that link the given start to end nodes.
  d) If the array of routes is empty, then there is no solution.
  e) Each path / link /edge traversed is assigned a cost of 1. That way
     the total cost of any route is equal to the number of steps required
     to get from start to end.
=end
require "#{ARGV[0]}/RPCFN3_classes"  # edited for unit test by ashbb
class Maze
  attr_reader :from, :to, :map

  def initialize(maze)
    @map = Network.new
    add_map_nodes(maze)      # load all navigable locations/points into the map
    build_links              # create links / paths / edges that link adjacent points
    map.get_routes(from, to) # create the list of routes that link the start and end points
  end

  def solvable?
    map.route_count > 0 ? true : false
  end

  def steps
    route_count > 0 ? map.min_cost_routes.first.cost : 0
  end

  def route_count
    map.routes.count
  end

private

  def add_map_nodes(maze)
  # Load nodes that correspond to maze coordinates which
  # can be traversed. (i.e. spaces, not bricks)
  # Also record start end end points.
    r = c = 0
    maze.chars.to_a.each do |ch|
      node_id = r.to_s + '_' + c.to_s
      case ch
        when ' '
          map.add_node(Node.new(node_id))
        when '#' #dump the bricks
        when 'A'
          map.add_node(Node.new(node_id))
          @from = node_id
        when 'B'
          map.add_node(Node.new(node_id))
          @to = node_id
      else #reached end of row
        r += 1
        c = -1
      end
      c += 1
    end
  end
  def build_links
    map.nodes.each_pair do |id, node|
    # construct names of potential neighbors
    # if it exists create the link
      loc = id.split('_') #node location: row and column
      nxt = "#{loc[0]}_#{(loc[1].to_i + 1).to_s}"
      prv = "#{loc[0]}_#{(loc[1].to_i - 1).to_s}"
      up   = "#{(loc[0].to_i - 1).to_s}_#{loc[1]}"
      dwn = "#{(loc[0].to_i + 1).to_s}_#{loc[1]}"
      [nxt, prv, up, dwn].each {|n| node.add_path(Path.new('', id, n, 1)) if map.has_node?(n)}
    end
  end
end