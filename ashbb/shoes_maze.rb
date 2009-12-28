# shoes_maze.rb
require 'mazes'
require 'mod'

class Maze < Shoes
  include Mod
  url '/', :index
  url '/(.*)', :index
  
  def index n = 0
    mazes = [MAZE1, MAZE2, MAZE3, MAZE4, MAZE5][n = n.to_i]
    background darkorange
    nostroke
    style Link, :underline => nil, :stroke => white
    style LinkHover, :fill => nil, :stroke => white
    style Para, :stroke => white , :weight => 'bold'
    
    @maze, @found = {}, false
    colors = {'#' => forestgreen, ' ' => white, 'A' => red, 'B' => blue}
    
    stack :top => 30, :left => 10, :width => 370, :height => 130 do
      mazes.each_line.with_index do |line, y|
        line.chomp.split('').each.with_index do |c, x|
          @maze[[x, y]] = rect x*10, y*10, 10, 10, :fill => colors[c], :prev => nil
          @hunters = [@start = [x, y]] if c == 'A'
          @goal = [x, y] if c == 'B'
        end
      end
      
      @balloon = stack :left => 30, :top => 20, :width => 310, :height =>90 do
        background rgb(255, 255, 255, 0.8), :curve => 10
        @msg = subtitle '', :align => 'center', :top => 20
      end.hide
    end
  
    para "MAZE#{n+1}", :left => 10
    para link('solvable?').click{solv}, :left => 10, :top => 160
    @solution = para(link('solution').click{solution}, :left => 100, :top => 160).hide
    para link('next', :click => "/#{(n+1)%5}") , :left => 330, :top => 160
  end
end

Shoes.app :width => 390, :height => 190, :title => 'Maze Hunter 2 r0.2', :resizable => false
