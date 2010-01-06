class Maze
  def initialize(map)
    @m_iPathLength=nil
    @m_bSolvable=nil
    @m_aMap=map.split(/\n/)
  end

  def build
    @m_bSolvable,@m_iPathLength=walk
    @m_bSolvable
  end

  def walk
    start_pos=(@m_aMap.join=~/A/)
    unless start_pos.nil? || !(@m_aMap.join=~/B/) #unless no start or end
      width=@m_aMap.collect {|x| x.size}.max #should have boundary wall anyway
      height=@m_aMap.size
      queue=[[start_pos/width,start_pos%width,0]] #initialize stack with start x,y and depth
      visited={}
      while !queue.empty?
        x,y,depth=queue.pop
        hash_index="#{x}_#{y}"
        visited[hash_index].nil? ? visited[hash_index]=true : next
        case @m_aMap[x][y].chr
        when ' ','A'
          queue.push([x,y-1,depth+1]) if y>0      #checks are redundant if boundary wall completely
          queue.push([x,y+1,depth+1]) if y<width  #surrounds the maze, but add to flexibility if there
          queue.push([x-1,y,depth+1]) if x>0      #is a start position on the boundary.
          queue.push([x+1,y,depth+1]) if x<height 
        when 'B'
          return [true,depth]
        end
      end
    end
    return [false,0] #fail if we got to here
  end

  def solvable?
    @m_bSolvable || build
  end

  def steps
    solvable? ? @m_iPathLength : 0
  end
end

#There were lots of choices for this particular test, but I thought that I'd go for brevity and meeting
#the stated requirement rather than leave in all of the extra code I had (printing the final solution, by
#storing a parent in the visited and passing it to the stack, etc.) The code first converts the map to
#an array of strings and finds the start position. From this it then adds in all of the boxes bounding
#this to a stack and examines them in turn, adding other bounding squares to the stack of places to 
#be examined as it goes on. If a cell has been previously visited, or doesn't contain a path, it is
#skipped and the next one in the stack is examined. In addition to the cell location, the distance from
#the starting square is passed to the stack, which means, when the final cell is reached, this variable
#(called depth) contains the shortest distance from the start to the end. The fail condition happens
#when there are no start or end squares, or when all possibilities have been traced from the start
#and have resulted in only dead ends without reaching the end point.

