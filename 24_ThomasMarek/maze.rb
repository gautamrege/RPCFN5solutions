require 'jcode'
require 'thread'


class Maze
  class Field
    START_POINT_CHAR = 'A'.freeze
    END_POINT_CHAR = 'B'.freeze
    NAVIGATABLE_CHARS = [' '.freeze, START_POINT_CHAR, END_POINT_CHAR]

    attr_reader :row
    attr_reader :column

    def initialize(maze, row, column, char)
      @maze = maze
      @row = row
      @column = column
      @char = char
    end

    def ==(other)
      other.is_a?(self.class) and other.row == @row and other.column == @column
    end

    def navigatable?
      @is_navigatable ||= NAVIGATABLE_CHARS.include?(@char)
    end

    def start_point?
      @is_start_point ||= (@char == START_POINT_CHAR)
    end

    def end_point?
      @is_end_point ||= (@char == END_POINT_CHAR)
    end

    def navigatable_neighbors
      @navigatable_neighbors ||= [
        @maze.field(@row + 1, @column),
        @maze.field(@row, @column + 1),
        @maze.field(@row - 1, @column),
        @maze.field(@row, @column - 1)
      ].select {|neighbor| not neighbor.nil? and neighbor.navigatable? }
    end
  end

  def initialize(input)
    @fields = parse_input(input)
  end

  def solvable?
    @is_solvable ||= (steps > 0)
  end

  def steps   
    @steps ||= MazeSolver.new(self).steps_to_end_point
#    @steps ||= ThreadedMazeSolver.new(self).steps_to_end_point
  end

  def field(row, column)
    @fields.fetch(row, {})[column]
  end

  def start_point
    if @start_point.nil?
      @fields.each_value do |fields|
        break if @start_point = fields.values.detect {|field| field.start_point? }
      end
    end

    raise "No start point found" if @start_point.nil?

    @start_point
  end

private    
  def parse_input(input)
    fields = {}
    row = 0

    input.each_line do |line|
      fields[row] = {}
      column = 0

      line.each_char do |char|
        fields[row][column] = Field.new(self, row, column, char)
        column += 1
      end

      row += 1
    end

    fields
  end
end


class MazeSolver
  def initialize(maze)
    @maze = maze
  end

  def steps_to_end_point
    @steps_to_end_point ||= find_end_point(@maze.start_point)
  end

protected
  def find_end_point(current_field, origin_field=nil)
    current_field.navigatable_neighbors.each do |next_field|
      return 1 if next_field.end_point?
      next if next_field == origin_field
      steps = find_end_point(next_field, current_field)
      return steps + 1 if steps > 0
    end

    0
  end
end

# Should be faster with big maze
class ThreadedMazeSolver < MazeSolver
protected
  def find_end_point(current_field, origin_field=nil)
    next_fields = current_field.navigatable_neighbors
    use_threads = ((origin_field.nil? and next_fields.size > 1) or next_fields.size > 2)
    threads = []
    thread_results = (use_threads ? Queue.new : nil)

    begin
      next_fields.each do |next_field|
        return 1 if next_field.end_point?
        next if next_field == origin_field

        if use_threads
          threads << Thread.new(thread_results) do |thread_results|
            thread_results << find_end_point(next_field, current_field)
          end
        else
          steps = find_end_point(next_field, current_field)
          return steps + 1 if steps > 0
        end
      end

      unless threads.empty?
        threads_counter = threads.size

        while threads_counter > 0
          steps = thread_results.pop
          return steps + 1 if steps > 0
          threads_counter -= 1
        end
      end

      return 0
    ensure
      threads.each {|thread| thread.kill }
    end
  end
end