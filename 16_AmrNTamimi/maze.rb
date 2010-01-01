class Maze

  def initialize(string)
    @data = string
    @c = @w = @h = 0
    @c = string.length
    string.each_line {|s| @h +=1}  # replaced each to each_line by ashbb
    @w = @c / @h
    @s = []
    @g = []
    @number_of_steps = 0 # expect the worst
    @a = @b = @goal = @start = 0
  end

  def steps
    i = 0
    @data.chomp.each_line do |l|  # replaced each to each_line by ashbb
      l.chomp.each_char do |ch|
        @s[i] = @g[i] = -1
        @s[i] = -2 if ch == '#'
        @start = i if ch == 'A'
        @goal = i if ch == 'B'
        i +=1
      end
    end
    @a = @b = @goal
    while @a != @start
      return 0 if @a == -2
      add(@a,1)
      add(@a,-1)
      add(@a,@w)
      add(@a,-@w)
      @a = @s[@a]
    end
    while @a != @goal
      @number_of_steps +=1
      @a +=@g[@a]
    end
    @number_of_steps
  end

  def solvable?
    i = 0
    @data.chomp.each_line do |l|  # replaced each to each_line by ashbb
      l.chomp.each_char do |ch|
        @s[i] = @g[i] = -1
        @s[i] = -2 if ch == '#'
        @start = i if ch == 'A'
        @goal = i if ch == 'B'
        i +=1
      end
    end
    @a = @b = @goal
    while @a != @start
      return false if @a == -2
      add(@a,1)
      add(@a,-1)
      add(@a,@w)
      add(@a,-@w)
      @a=@s[@a]
    end
    return true
  end

  def add(p, o)
    if @s[p+o] == -1
      @s[@b] = p+o
      @b = p+o
      @g[p+o] = -o
    end
  end

end