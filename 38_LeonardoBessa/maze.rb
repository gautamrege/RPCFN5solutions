class Maze
  attr_reader :start_point, :end_point
  def initialize map
    @cell_map = map.lines.map { |b|  b.scan(/./)}
    map.lines.each_with_index do |line,line_index|
      @start_point ||= [line_index,line.index('A')] if line.include?('A')
      @end_point   ||= [line_index,line.index('B')] if line.include?('B')
      break if @start_point and @end_point
    end
  end

  def solvable?
    @steps = 1
    origins = [start_point]
    until origins.empty?
      selected_neighbors = []
      origins.each do |(x,y)|
        neighbors = [[x-1,y],[x+1,y],[x,y-1],[x,y+1]]
        return true if neighbors.include? @end_point 
        selected_neighbors += neighbors.find_all do |(a,b)|
          @cell_map[a][b] = @steps if @cell_map[a][b] == " "
        end
      end
      origins = selected_neighbors
      @steps += 1
    end
    false
  end

  def steps
    solvable? ? @steps : 0
  end

end