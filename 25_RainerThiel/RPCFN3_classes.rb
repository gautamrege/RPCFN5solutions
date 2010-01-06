=begin
Network - outer container, a collection of node objects
Node    - a point in the network that can be reached via at least one pathway.
          includes a collection of paths that point to neighboring nodes.
Path    - a link or association between 2 nodes. A path between 2 nodes implies
          that they are neighbors.
          Each path has a cost attribute, a generalization of things such as
          resistance, distance, weight, difficulty, traffic density,
          the toll or outlay or price incurred when following the path from
          one end to the other.
Route   - A pathway that connects 2 nodes defined as start and destination nodes.
          There can be many different routes between 2 chosen nodes.
          There can be one or more routes that have the same cost
=end
###########################################
class Network ############################
###########################################
#
# The outer container.
# A collection of Node objects, hashed for easy location of specific nodes
# Synonyms: Map, CircuitBoard, ...
#
# Its behaviour includes the ability to find all the possible routes
# between any 2 nodes (the start and end nodes). see get_routes
#
  attr_reader :name,            # a unique identifier
              :nodes,           # hash of nodes where the key is the node name
              :routes,          # array of routes populated when start and end nodes are provided
                                # see method get_routes
              :max_cost,        # max cost incurred following a specified route
              :max_cost_routes, # list of routes that share max cost
              :min_cost,        # min cost incurred following a specified route
              :min_cost_routes, # list of routes that share min cost
              :avg_cost         # average cost incurred across all routes
  def initialize(name = 'myMap', nodes = [])
    @name = name
    @nodes = {}
    @routes = []
    nodes.each {|n| @nodes.store(n.name, n)}
    init_stats
  end
  
  def import(paths) # import RPCFN3 format map data
    paths.each do |p_in|
      p_to = Path.new('', p_in[0],p_in[1],p_in[2])
      p_reverse = p_to.reverse
      [p_to, p_reverse].each do |p|
        if has_node?(p.from)
          node(p.from).add_path p
        else  
          add_node Node.new(p.from, p)
        end  
      end    
    end    
  end
  
  def export # export to RPCFN3 format TODO
  end  
  def has_node?(node) # some overloading
    if node.kind_of? String
      @nodes.has_key?(node)
    elsif node.kind_of? Node
      @nodes.has_key?(node.name)
    else
      false
    end
  end
  
  def is_empty?
    @nodes.length == 0
  end
  
  def node(node)
    if node.kind_of? String
      @nodes[node]
    elsif node.kind_of? Node
      @nodes[node.name]
    else
      false
    end  
  end  
  
  def add_node(node) # single Node assumed if not array of nodes
    node = [node] unless node.kind_of? Array
    node.each {|n| @nodes.store(n.name, n)}
  end
  
  def node_count
    @nodes.length
  end

  def neighbors(node) #neighboring nodes
    node = node(node) if node.kind_of? String
    node.paths.keys.collect {|pk| node(pk)}
  end
  
  def path_count
    nodes.values.inject(0) {|cnt, n| cnt+= n.path_count}
  end

  def path(path_name)
  # TODO:
  # Making shaky assumptions wrt path name format, as follows:
  # 1. Format is <from_nodename>_<to_nodename>
  # 2. nodenames may not contain underscores
  # It works for RPCFN3 but certainly requires some
  # attention for use beyond that.
    node(path_name.split('_').first).path(path_name.split('_').last)
  end
  def path_list # array of all paths in the network
    nodes.values.collect {|n| n.paths.values}.flatten
  end

  def route_count
    routes.length
  end

  def get_routes(from, to)
    #
    # The stack is processed as a LIFO queue
    # Each entry includes a node identifier (name) and a tail of breadcrumbs
    # that include the nodes we have traversed to get to this entry's node.
    #
    # The traverse_node method processes the top stack entry (index=0)
    # 1. Identify all possible next steps from here
    # 2. Filter out possible destinations that we have already visited
    # 3. Remove the top stack entry, been there, done that.
    # 4. If we have not yet reached the end node, then
    #      put valid next steps onto the stack, each with breadcrumbs attached
    #    otherwise
    #      create a route from the bradcrumbs and save it
    #
    @from = from
    @to = to
    @stack = [[from, []]]
    @routes = []
    traverse_node until @stack.empty?
    calc_stats
  end
  
  private

  def traverse_node # This is the heart of the challenge
    here = @stack.first[0]
    crumbs = @stack.first[1] + [here] # list of node names that show where we came from
    nb = neighbors(here).collect {|n| n.name} # all possible nodes we can reach from here
    next_steps = nb - crumbs # remove nodes we have already been to
    @stack.delete_at(0) # remove the top stack entry
    if here != @to # Not there yet..
                   # pile next step nodes with breadcrumbs on top of stack
      next_steps.each { |nn| @stack.insert(0, [nn, crumbs])}
    else # We have reached the destination node.
         # The nodes traversed are in crumbs.
         # Create a list of nodes traversed and hook on each the actual path followed
         # Use that list to create a new route object an add it to the list of routes
      rnodes = []
      crumbs.each_index do |i|
        rn = Node.new(crumbs[i])
        rn.add_path(node(crumbs[i]).path(crumbs[i + 1])) unless i == (crumbs.length - 1)
        rnodes << rn
      end
      routes << Route.new("#{@from}_#{@to}_#{routes.length + 1}", node(@from), node(@to), rnodes)
    end
  end
  
  def calc_stats
    init_stats
    costs = routes.collect {|r| r.cost}
    costs.each {|d| @max_cost = d if d > @max_cost}
    @min_cost += @max_cost
    costs.each do |d|
      @min_cost = d if d < @min_cost
      @avg_cost += d
    end
    @avg_cost /= (routes.count > 0 ? routes.count : 1)
    #finally save a list of routes that share min / max values
    #format key is the cost, value is an array of matching routes
    routes.each do |r|
      @min_cost_routes << r if r.cost == @min_cost
      @max_cost_routes << r if r.cost == @max_cost
    end
  end

  def init_stats
    # max and min stats are implemented as hash to cater
    # for more than one route with min or max values
    @max_cost = @min_cost = @avg_cost = 0
    @max_cost_routes = []
    @min_cost_routes = []
    
  end
end

###########################################
class Node ##################################
###########################################

  attr_reader :name,      # a unique identifier
              :paths      # a list of Path objects that lead us to adjacent nodes
                          # *Note* as implemented here (hash where key is
                          # the destination node identifier) we can only have
                          # one path that connects any 2 nodes.
                          # TODO: Allow more than one path between 2 nodes, ensuring
                          # that there is a cost (distance/weight/resistance)
                          #  difference between them - (otherwise it makes no sense?)
  def initialize(name, paths = [])
    @name = name
#    paths.kind_of?(Path) ? @paths = [paths] : @paths = paths
    @paths = {}
    paths.kind_of?(Path) ? @paths.store(paths.to, paths) : paths.each {|p| @paths.store(p.to, p)}
  end
  
  def is_orphaned?
    paths.length == 0
  end
  
  def add_path(path) #String assumed if not array of paths
    path.kind_of?(Path) ? @paths.store(path.to, path) : path.each {|p| @paths.store(p.to, p)}
  end

  def path(path)
    if path.kind_of? String
      @paths[path]
    elsif path.kind_of? Path
      @paths[path.to]
    else
      false
    end
  end
  
  def cost(node)
    @paths[node.kind_of?(Node) ? node.name : node].cost
  end

  def clear_paths
    @paths = []
  end
  
  def path_count
    @paths.length
  end

end

###########################################
class Path ##################################
###########################################
  attr_reader :name,           # a unique identifier
                  :from, :to,  # connecting node names. "from" is redundant, "to" is the destination node
                  :cost        # alias distance, resistance, weight ...
  def initialize(name, from, to, cost)
    @name = name == '' ? "#{from}_#{to}" : name
    @from = from
    @to = to
    @cost = cost
  end
  def reverse
    Path.new(@name == "#{@from}_#{@to}" ? '' : @name, @to, @from, @cost)
  end
  def to_a #build output format for ROCFN3
    [@from, @to, @cost]
  end
end

###########################################
class Route ##############################
###########################################
  attr_reader :name,                      # a unique identifier
                  :origin, :destination,  # the start and end nodes
                  :nodes,                 # list of nodes traversed en route
                  :cost                   #incurred following this route
  def initialize(name, origin, destination, nodes = [])
    @name = name == '' ? "#{origin.name}_#{destination.name}" : name
    @origin = origin
    @destination = destination
    @nodes = nodes
    @cost = calculate_cost
  end
  def add_node(node) # single Node assumed if not array of nodes
    node = [node] unless node.kind_of? Array
    node.each {|n| @nodes.store(n.name, n)}
  end
  def path_list # array of all paths in the route
    nodes.collect {|n| n.paths.values}.flatten
  end

  def reverse # the return route
    rev = nodes.reverse
    i = 0
    begin
      rev[i].add_path(rev[i+1].paths.values.first.reverse)
      rev[i+1].clear_paths
      i += 1
    end until i = (rev.length - 2)
    Route.new(name == "#{origin.name}_#{destination.name}" ? '' : "Reverse of #{name}", destination, origin, rev)
    
  end
  
  private
  
  def calculate_cost
    nodes.inject(0) {|dist, n| dist += (n.paths.count == 1 ? n.paths.values.first.cost : 0)}
  end  
end

###########################################
class String # Playing around with bits of DSL ##############
###########################################
  def is_a_node_on(theMap) # the string here is the name of a node
    theMap.has_node?(self)
  end  
end  
