require "#{ARGV[0]}/tree"  # edited for unit test by ashbb

class Maze
    WALL_CHAR  = '#'
    START_CHAR = 'A'
    GOAL_CHAR  = 'B'

    def initialize(maze)
        @maze = maze.lines.map { |l| l.chomp.split '' }
        determine_start
        @tree = build_path_tree
    end

    def solvable?
        @tree.contains? true
    end

    def steps
        if ! self.solvable? then
            0
        else
            @tree.minimal_pathlength_to true
        end
    end

    def at(x, y)
        @maze[y][x]
    end

    def wall_at?(x, y)
        @maze[y][x] == WALL_CHAR
    end

    def possible_directions_at(x, y, came_from = nil)
        directions = []
        raise ArgumentError 'y too big' if y >= @maze.size
        raise ArgumentError 'x too big' if x >= @maze[0].size
        raise ArgumentError "there is a wall at #{x},#{y}!" if wall_at?(x, y)
        directions = Direction.all.select do |d|
            # all directions where there is no wall and were we did not come from
            (! wall_at?(*Direction.goto(x, y, d))) && (d != came_from)
        end
    end

    private
    def determine_start
        @maze.each_with_index do |line, y|
            line.each_with_index do |char, x|
                if char == START_CHAR then
                    @start = [x, y]
                end
            end
        end
    end

    # Builds a tree with all paths through the maze.
    #
    # The 'name' of the tree elements is a boolean variable that
    # determines whether we have reached the goal ('B'). This way,
    # we can later just test whether the tree contains 'true' to
    # see if the maze is solvable
    def build_path_tree(x = @start[0], y = @start[1], came_from = nil)
        name = (at(x, y) == GOAL_CHAR)
        t = Tree.new(name)
        possible_directions_at(x, y, came_from).each do |d|
            new_x, new_y = Direction.goto(x, y, d)
            t.add_child(build_path_tree new_x, new_y, Direction.opposite(d))
        end
        t
    end
end

class Direction
    NORTH = [0, -1]
    SOUTH = [0, +1]
    WEST  = [-1, 0]
    EAST  = [+1, 0]

    def self.all
        self.constants.map { |d| self.const_get(d) }
    end
    
    def self.opposite(dir)
        dir.map { |d| -1 * d }
    end

    def self.goto(x, y, dir)
        [x + dir[0], y + dir[1]]
    end
end
