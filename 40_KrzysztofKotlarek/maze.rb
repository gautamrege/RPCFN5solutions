class Maze
  attr_reader :steps
  def initialize(maze)
    #make array
    @tab = maze.split('')

    #find A and B
    @start = find_start
    @end = find_end

    @solvable = false
    @steps = 0

    #start queue
    @q = []
    @q = [@start, 0]

    #algorithm
    work_with_queue
  end

  def solvable?
    @solvable
  end

  private
  def find_start
    @tab.index('A')
  end
  def find_end
    @tab.index('B')
  end

  def find_helper(a)
    if @tab[a] == " "
      return a
    elsif @tab[a] == 'B'
      return "finish"
    else
      return nil
    end
  end
  #find neighbours
  def find_top(a)
    find_helper(a-38)
  end
  def find_bottom(a)
    find_helper(a+38)
  end
  def find_left(a)
    find_helper(a-1)
  end
  def find_right(a)
    find_helper(a+1)
  end

  #mark neighbours
  def mark_neighbour(position,step)
    if position and position != "finish"
      @tab[position] = step
      @q << position << (step + 1)
    end
    if position == "finish"
      @steps = step + 1
      @solvable = true
    end
  end
  def find_and_mark_neighbour(position,step)
    mark_neighbour(find_top(position),step)
    mark_neighbour(find_bottom(position),step)
    mark_neighbour(find_left(position),step)
    mark_neighbour(find_right(position),step)
  end

  def work_with_queue
    while @q.count > 0
      position = @q.shift
      step = @q.shift
      find_and_mark_neighbour(position,step)
    end
  end
end