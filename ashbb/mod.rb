# mod.rb

module Mod  
  def go hunter  
    x, y = hunter
    [[x+1, y] , [x, y+1], [x-1, y], [x, y-1]].each do |a, b|
      if [a, b] == @goal
        @found = true
        @maze[[a, b]].style :prev => hunter
        return
      end
      if @maze[[a, b]].style[:fill] == white
        @maze[[a, b]].style :fill => khaki
        @maze[[a, b]].style :prev => hunter
        @hunters << [a, b]
      end
    end
    @hunters.delete hunter
  end
  
  def solv
    a = animate do
      if @found or @hunters.empty?
        @msg.text = @found ? 'Yes, solvable!' : 'No, not solvable.'
        a.stop; @balloon.show; @msg.show; timer(1){@balloon.hide; @msg.hide}
        @solution.show if @found
      else
        @hunters.each{|hunter| go hunter}
      end
    end
  end
  
  def solution
    hunter = @maze[@goal].style[:prev]
    a = animate do
      a.stop if @maze[hunter].style[:prev] == @start
      @maze[hunter].style(:fill => deepskyblue)
      hunter = @maze[hunter].style[:prev]
    end
  end
end
