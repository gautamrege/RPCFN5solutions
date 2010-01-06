#Author : Suraj Dhakankar-(India)	Dated 4th Jan '10

#Class Maze solves any m X n maze for given source and destination
class Maze
def initialize m
  @maze=m; @range=(0...m.length)
  @adjacent=[-1,1,-m.index($/)-1,m.index($/)+1] #offset [LEFT, RIGHT, UP, DOWN]
end
def steps
  blocks=[@maze.index('A'), nil]                #Start from source block in the first step
  blocks.each do |b|
    return 0 if b==nil && blocks.last==nil    #Destination block not reachable
    if b==nil then blocks<<nil; next end      #Keep track of no. of steps
    @adjacent.each do |a|                       #For all adjacent blocks to the current
      #Process the adjacent block in next step if it is valid free space not processed earlier
      blocks<<b+a if @range.include?(b+a) && ' '==@maze[b+a,1] && !blocks.index(b+a)
      #Return no. of steps if we hit destination block in any of the valid adjacent block
      return blocks.length-blocks.nitems if @range.include?(b+a) && 'B'==@maze[b+a,1]
    end
  end
end
def solvable?
  return 0!=steps
end
end