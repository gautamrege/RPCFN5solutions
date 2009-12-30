# maze.rb, by Othmane Benkirane.
# only tested with ruby 1.9.1p376 (2009-12-07 revision 26041).
# will definitely not work with ruby 1.8.
=begin
  Algorithm for steps:
  - @steps is populated with the starting cell in the beginnign ('A')
  - Until a solution is found, @steps replaces its content by the
    possible next steps
  - If a solution is found, the number is returned, if a solution isn't found
    (if @steps is empty), an error is raised (the loop is broken) and rescued
    to return 0
  
  Algorithm for solvable?:
  - steps must be superior to zero, since if it's zero, there is no solution.
=end
# Shortcuts
class String
  def chars
    split(//)
  end
end
class Integer
  def prev
    self - 1
  end
end

class Maze
  # Raised when there is no solution
  SolutionNotFound = Class.new(StopIteration)
  # @labyrinth is generated in the initialize method, and
  # is the string's array: each row contains one array of cells, which
  # enables the cell calling like that: @labyrinth[row][column]
  # it is used later by cells to find their relative neighbours.
  attr_reader :labyrinth
  def initialize(string)
    # Making it a 2-D array
    @labyrinth = string.lines.map {|row| row.chomp.chars}
    # Because the cells aren't unique, it's better to hardcode
    # their coordinates by turning them into a Cell element, which
    # is explained later and takes the coordinates and the maze as an argument.
    @labyrinth.map!.with_index do |row, row_index|
      row.map!.with_index do |value, column_index|
        Cell.new value:value, row:row_index, column:column_index,maze:self
      end
    end
    # The starting cell is used to create an initial step, which is used in
    # #steps to begin the solution searching
    start_cell = @labyrinth.flatten.find {|cell| cell.status == :start}
    (@steps = []) << Step.new(cell:start_cell,number:0)
  end
  # If a solution is found, steps must be superior to 0, since A and B can't
  # be on the same cell. In #steps, 0 is returned if there is no solution.
  def solvable?
    steps > 0
  end
  def steps
    # An infinite loop until the solution is found, or no ways left
    # which means there's no solution : an exception is raised and rescued
    # to return 0.
    until output = @steps.find {|step| step.cell.status == :stop}
      @steps.map! do |step|
        step.next_steps # replaces the step by its correct neighbours
      end
      # @steps is flattened since step.next_steps generates an array.
      raise SolutionNotFound if @steps.flatten!.empty?
    end
    output.number # we just want an integer.
  rescue SolutionNotFound
    return 0
  end
  class Step
    attr_reader :cell, :number, :previous
    # Cell: the cell where the step it
    # Count: the step number
    # Previous: the previous step, because we don't want to go back
    
    # params: cell(Maze::Cell), number(Integer), previous(Step, not required)
    def initialize(params = {})
      # @previous is nil if there is no params[:previous] given
      @cell,@number,@previous = params[:cell],params[:number],params[:previous]
    end
    
    # Takes all the cell's neighbours, converts them into a new step,
    # and rejects every '#' one and the previous one, which is not
    # a good way because we don't want to go back.
    def next_steps
      @cell.neighbours.map do |cell|
        Step.new(cell:cell,number:@number+1,previous:self)
      end.reject { |step| (step.cell.status == :wall)}.reject do |step|
        step.cell == @previous.cell if @previous 
        # we must add 'if @previous' since, if it's the starting cell,
        # @previous is nil.
      end
    end
  end
  
  class Cell
    attr_reader :row, :column, :status
    # Row, Column: row and column _number_.
    # Maze: the related maze. Used to find the neighbours by taking
    # its 2-d labyrinth
    # the status is dynamically generated from the given value
    
    # params: row(Integer), column(Integer), value(String), maze(Maze)
    def initialize(params = {})
      @row, @column = params[:row], params[:column]
      @laby = params[:maze].labyrinth # the maze labyrinth
      {empty:' ',wall:'#',start:'A',stop:'B'}.each do |status, value|
        @status = status if value == params[:value]
      end
    end
    def neighbours
      # up/down, right/left
      [@laby[@row][@column.succ], @laby[@row][@column.prev],
      @laby[@row.succ][@column], @laby[@row.prev][@column]]
    end
    
    # Used by Maze::Step#neighbours to remove the previous cell from the
    # next steps.
    def ==(other)
      return false unless self.class === other
      other.row    == @row &&
      other.column == @column &&
      other.status == @status
    end
  end
end