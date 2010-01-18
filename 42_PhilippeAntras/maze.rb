START   = 'A'
ARRIVAL = 'B'
WALL    = '#'
SPACE   = ' '
VISITED = '.'

class Maze
    def initialize(mazestring)
        @steps = 0
        @solvable = false
        maze_string_to_array(mazestring)
        start_point = localize_start_point()
        explore(*start_point)
    end
    def solvable?
        @solvable
    end
    def steps
        @steps
    end
    def maze_string_to_array(mazestring)
        @maze = []
        mazestring.each do |line|
            @maze.push line.chomp
        end
    end
    def localize_start_point
        @maze.each_index do |i|
            if j = @maze[i].index(START)
                return [i, j]  
            end
        end
    end
    def get_cell(x, y)
        @maze[x][y, 1]
    end
    def mark_cell(x, y, value)
        @maze[x][y, 1] = value
    end
    def explore(x, y, step=0)
        cell = get_cell(x, y)
        case cell
        when WALL, VISITED then return
        when ARRIVAL
            if (! @solvable || step < @steps)
                @steps = step
            end
            @solvable = true
            return
        when START  
            return unless (step == 0)   # stop exploring if back to start point
        when SPACE
            mark_cell(x, y, VISITED)
        else
            abort "ABORT: unknown cell : '#{cell}'" 
        end

        step += 1
        explore(x-1, y,   step)
        explore(x,   y+1, step)
        explore(x+1, y,   step)
        explore(x,   y-1, step)
        mark_cell(x, y, SPACE) unless (cell == START)  
    end

end
