# AN INFECTIOUS SOLUTION FOR SOLVING MAZES
#
# A maze consists of a network of cells which can be empty or infected
# by a virus.  A virus is an organism that lives in a single cell.  It
# divides and spreads to adjacent cells.  A virus keeps track of what
# generation it is--the number of divisions that have occured since
# the introduction of the first virus into the maze.
#
# The younger the virus, the stronger it is.  As a virus spreads, it
# divides and takes over adjacent cells that are either normal or
# already infected with an older, weaker virus.  This approach ensures
# that after the infection has spread completely across the maze, only
# the youngest virus will survive at B and the generation number will
# represent the shortest possible number of steps required to reach B.
#
# This solution was an experiment in the use of a metaphor and
# syntactic features of Ruby for a literate, prosy presentation. It 
# also has lots of cowbell.
#
# Maze solution by Bill Kayser, bkayser@newrelic.com
# Jan 16, 2010
#
# 
#

require 'stringio'

class Maze
  
  # A maze is solvable if an infection placed at
  # point A eventually spreads point B.

  def solvable?
    infect the cell at a
    while we have more? new_infections and not infected? at b do
      spread a new_infection
    end
    is infected? at b
  end   
  
  # We can determine the steps from A to B by infecting the maze at A,
  # waiting until there are no more new infections, and then seeing
  # what generation virus occupies point B.

  def steps
    infect the cell at a
    while we have more? new_infections do
      spread a new_infection
      more cowbell!
    end
    if the maze is infected? at b then return the generation at b else return 0 end
  end
  
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
  
  # A set of newly infected cells which are ready to spread the 
  # infection to nearby cells
  attr_reader :new_infections

  # The Map that keeps track of the content of all the cells
  attr_reader :map
 
  def initialize(maze)
    @map = Map.new(maze)
    @new_infections = []
  end
  
  # Take the virus from the given cell and infect each neighboring cell.
  # Yes, it's repetitive, but I thought it reads nicer.  
  def spread(infectious_cell)
    infectious_cell.virus.divide.infect cell north of infectious_cell
    infectious_cell.virus.divide.infect cell south of infectious_cell
    infectious_cell.virus.divide.infect cell east of infectious_cell
    infectious_cell.virus.divide.infect cell west of infectious_cell
  end

  # DSL Methods
  #
  # These are just simple methods and connectors for expressing the
  # algorithms in the solvable? and steps methods.
  #
  def cell(loc)
    @map[loc]
  end
  
  def north(cell); Loc.new(cell.loc.row - 1, cell.loc.col); end
  def south(cell); Loc.new(cell.loc.row + 1, cell.loc.col); end
  def east(cell); Loc.new(cell.loc.row, cell.loc.col + 1); end
  def west(cell); Loc.new(cell.loc.row, cell.loc.col - 1); end
  
  def infect(cell)
    Virus.new(self).infect(cell)
  end
  
  def more?(list)
    list && list.size > 0
  end
  
  def infected?(loc)
    (cell at loc).infected?
  end
  
  def generation(loc)
    (cell at loc).virus.generation
  end

  # Could be either an article or a reference to position a
  def a(*args)
    return map.a if args.empty?
    super
  end
  
  def b
    map.b
  end
  
  # Get the next location off the list of new infections
  def new_infection
    new_infections.shift
  end
  
  # This just allows us to throw in little connector words in the
  # algorithms for readability.  If a method isn't found it just skips
  # it by passing the arg along to the return value.
  def method_missing(method, *args)
    args[0]
  end
  
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Supporting Classes
  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  
  #
  # A Virus has a location and knows what generation it is.  When it
  # divides it bumps the generation.
  #
  class Virus
    
    attr_accessor :generation
    
    def initialize(maze, generation = 0)
      @maze = maze
      @generation = generation
    end
    
    # Return self if you successfully infect the cell, otherwise nil
    def infect(cell)
      if cell && (cell.empty? || (cell.infected? && cell.virus.generation > self.generation))
        cell.virus = self
        # Add the cell to the list of newly infected cells, if it's not already
        # on the list.
        @maze.new_infections << cell unless @maze.new_infections.include? cell
      end
    end
    
    def divide
      Virus.new @maze, generation + 1
    end

  end
  
  #
  # A Map represents the contents of all the cells in the maze,
  # addressable by Loc objects.  It's initialized with the ASCII input
  # data.
  #
  class Map
    
    attr_reader :a, :b
    
    def initialize(data)
      @data = []
      StringIO.new(data).readlines.each_with_index do |line, rownum |
        @data << []
        line.chomp.chars.each_with_index do | char, colnum |
          loc = Loc.new(rownum, colnum)       
          @data.last << Cell.new(char, loc)
          @a = loc if char == 'A'
          @b = loc if char == 'B'
        end
      end
    end
    
    def [](loc)
      return nil if loc.row < 0 || loc.col < 0
      @data[loc.row][loc.col]
    end

    # I used this while developing the solution
    def show
      @data.each do | row |
        row.each do | cell |
          if cell.infected?
            print "%3s" % cell.virus.generation
          else
            print " #{cell.content} "
          end
        end
        puts
      end
    end
    
  end
  
  #
  # A Cell represents what occupies a maze at a particular location
  #
  class Cell

    attr_accessor :virus
    attr_reader :loc, :content
    
    def initialize char, loc
      @content = char
      @loc = loc
    end

    def empty?
      [' ', 'A', 'B'].include?(@content) && virus.nil? 
    end

    def infected?
      not virus.nil?
    end
    
  end

  
  #
  # Loc represents a position in the map by row and column.
  #
  class Loc

    attr_reader :row, :col

    def initialize(row,col)
      @row, @col = row, col
    end

  end
  
end
