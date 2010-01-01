=begin
SOlUTION FOR MAZE RUBY QUIZ 12/30/09
usage: Maze.new(maze_as_a_string)
instance_methods: #solvable?, #steps
=end
class Maze
  def initialize(maze_name)
    @data = maze_name
  end
  def steps
    if !@info
      solvable?
    end
    @info[:steps]
  end
  def solvable?
    create_clean_board
    #find start (A)
    @maze.each_with_index{|r,i| @start = [i, r.index('A')] if r.include?('A') }
    #find stop (B)
    @maze.each_with_index{|r,i| @stop = [i, r.index('B')] if r.include?('B') }
    #unless both a start and stop are found return false--the puzzle is not solvable
    unless @start && @stop
      @info = {:solvable? => false, :steps => 0}
      @info[:solvable?]
    end
    #prepare variables for loop
    @newNodes = []
    @newNodes << @start
    @step = 0
    while @newNodes.length != 0
      #uncomment the following line to print out the step-wise maze progress 
      #print_progression
      copy = @newNodes.dup   #copy all previous Nodes
      @newNodes = []         #empty container of Nodes. We'll restock this variable as we cycle

      #loop through the copied list of newNodes
      copy.each do |node|
        neighbors(*node).each do |neighbor|
          #test for the stop letter (B)
          if fetch_(*neighbor) == "B"
            @step += 1
            @info = {:solvable? => true, :steps => @step} #[true, @step]
            return @info[:solvable?]
          end
          #test for empty space into which we can advaance
          if fetch_(*neighbor) == " "
            #advance and place period (bread crum) at that site
            write_(*neighbor)
            #save the site as a newNode (the leading edge nodes are the sites for advancement next round)
            @newNodes.unshift neighbor
          end
        end
      end
      @step += 1
    end
    @info = {:solvable? => false, :steps => 0}
    @info[:solvable?]
  end

  private
  def create_clean_board
    #initialization is separate from instantiation so that the path can be traced onto the board and cleaned off if the method is run again
    @maze = @data.split(/\n/).collect{|row| row.split(//)}
  end
  def fetch_(r,c)
    @maze[r][c]
  end
  def write_(r, c)
    @maze[r][c] = "."
  end
  def neighbors(r,c)
    #up,    down,   left,   right
    array = [[r-1, c], [r+1,c],[r,c-1],[r,c+1]]
    array.reject!{|item| item[0]<0 }                    #reject any neighbors with rows below 0
    array.reject!{|item| item[0]>(@maze.length - 1)}    #reject any neighbors with rows higher than rows available
    array.reject!{|item| item[1]<0 }                    #reject any neighbots with columns below 0
    array.reject!{|item| item[1]>(@maze[0].length - 1)} #reject any neighbors with columns higher than columns available
    array
  end
  def print_progression
    puts @step
    @maze.each{|r| puts r.join }
  end
end
