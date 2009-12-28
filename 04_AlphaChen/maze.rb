class Maze
  def initialize(s)
    @m = s.dup
    @d = r(@m.index('A'),@m.index("\n")+1)
  end

  def r(a,w)
    n = [[1,a]]
    until n.empty? do
      d,i = n.shift
      [i-w,i+w,i-1,i+1].each do |j|
        case @m[j]
        when 32
          @m[j] = 'x'
          n << [d+1,j]
        when 66
          return d
        end
      end
      n.sort!
    end
    nil
  end

  def solvable?; !!@d; end
  def steps; @d || 0; end
end

