#
# Copyright (c) Yuri Omelchuk <jurgen@upscript.com>
#
# January 8, 2009
#
# Maze class written for RubyLearning contest
# http://rubylearning.com/blog/2009/12/27/rpcfn-mazes-5/
#
# solution is based on find shortest path algorithm 
#

class Maze

  WALL = '#'
  SPACE = ' '
  START = 'A'
  FINISH = 'B'

  def initialize(structure)

    # build a maze map
    @map = []
    structure.split("\n").each_with_index do |line, i|
      @map[i] = []
      line.each_char do |c|
        @map[i] << c
      end
    end

    solve   # use a find shortest path method to solve a maze
  end

  def solvable?
    (n, m) = find_start
    for (a, b) in neighbor_cells(n, m)
      return true if is_number?(a, b)
    end

    false
  end

  def steps
    s = []
    (n, m) = find_start

    # find possible multiple solutions and select minimal number of steps
    for (a, b) in neighbor_cells(n, m)
      if is_number?(a, b)
        s << @map[a][b]
      end
    end

    return s.empty? ? 0 : s.min + 1   # add 1 for very last step
  end

  def display
    for n in (0..@map.size - 1) do
      puts @map[n].map{|e| e.to_s.center(3)}.join(' ')
    end
  end

  protected

  def solve
    #start from finish
    @queue = []
    @queue << find_finish
    step = 1

    while !@queue.empty? do
      @queue = round(@queue, step)
      step += 1
    end
  end

  # perform a round in finding shortest path algorithm
  def round(queue, step)
    next_round = []
    while !queue.empty? do
      (n, m) = queue.shift
      for (a, b) in neighbor_cells(n, m)
        if space?(a, b)
          @map[a][b] = step
          next_round << [a, b]
        end
      end
    end
    next_round
  end

  # check if cell is empty
  def space?(n, m)
    @map[n][m] == SPACE
  end

  # check if cell contains a number (which means a step number)
  def is_number?(n, m)
    is_int(@map[n][m])
  end

  # return array of neighbor cells coordinates
  def neighbor_cells(n, m)
    cells = []
    cells << [n-1, m] if n > 0
    cells << [n+1, m] if n < height
    cells << [n, m-1] if m > 0
    cells << [n, m+1] if m < width
    return cells
  end

  # check if variable contains integer value
  def is_int(value)
    true if Integer(value) rescue false
  end

  # get width of the maze
  def width
    @map[0].size
  end

  # get height of the maze
  def height
    @map.size
  end

  # find a cell marked as start
  def find_start
    find_cell(START)
  end

  # find a cell marked as finish
  def find_finish
    find_cell(FINISH)
  end

  # find a cell coordinates by cell value
  def find_cell(key)
    for n in (0..@map.size - 1)
      for m in (0..@map[n].size - 1)
        if @map[n][m] == key
          return [n, m]
        end
      end
    end
  end

end