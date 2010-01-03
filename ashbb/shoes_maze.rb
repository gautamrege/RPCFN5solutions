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
    formats = %w[pdf ps svg]
    
    mazes.each_line.with_index do |line, y|
      line.chomp.split('').each.with_index do |c, x|
        @maze[[x, y]] = rect x*10+10, y*10+30, 10, 10, :fill => colors[c], :prev => nil
        @hunters = [@start = [x, y]] if c == 'A'
        @goal = [x, y] if c == 'B'
      end
    end
      
    @balloon = background(rgb(255, 255, 255, 0.8), :curve => 10, 
      :left => 40, :top => 50, :width => 310, :height =>90).hide
    @msg = subtitle('', :align => 'center', :top => 70).hide
  
    para "MAZE#{n+1}", :left => 10
    para link('solvable?').click{solv}, :left => 10, :top => 160
    @solution = para(link('solution').click{solution}, :left => 100, :top => 160).hide
    para link('snapshot:').click{_snapshot(:filename => "snapshot.#{formats.first}", 
      :format => formats.first.to_sym)}, :left => 200, :top => 160
    bg = image :left => 280, :top => 160, :width => 50, :height => 20
    msg= para formats.first, :left => 280, :top => 160
    bg.click{formats << formats.shift; msg.text = formats.first}
    para link('next', :click => "/#{(n+1)%5}") , :left => 330, :top => 160
  end
end

Shoes.app :width => 390, :height => 190, :title => 'Maze Hunter 2 r0.3b', :resizable => false
