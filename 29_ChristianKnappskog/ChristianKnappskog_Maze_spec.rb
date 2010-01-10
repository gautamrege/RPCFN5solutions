require 'spec'
require 'Maze'

MAZE1 = %{#####################################
# #   #     #A        #     #       #
# # # # # # ####### # ### # ####### #
# # #   # #         #     # #       #
# ##### # ################# # #######
#     # #       #   #     # #   #   #
##### ##### ### ### # ### # # # # # #
#   #     #   # #   #  B# # # #   # #
# # ##### ##### # # ### # # ####### #
# #     # #   # # #   # # # #       #
# ### ### # # # # ##### # # # ##### #
#   #       #   #       #     #     #
#####################################}
# Maze 1 should SUCCEED

MAZE2 = %{#####################################
# #       #             #     #     #
# ### ### # ########### ### # ##### #
# #   # #   #   #   #   #   #       #
# # ###A##### # # # # ### ###########
#   #   #     #   # # #   #         #
####### # ### ####### # ### ####### #
#       # #   #       # #       #   #
# ####### # # # ####### # ##### # # #
#       # # # #   #       #   # # # #
# ##### # # ##### ######### # ### # #
#     #   #                 #     #B#
#####################################}

# Maze 2 should SUCCEED

MAZE3 = %{#####################################
# #   #           #                 #
# ### # ####### # # # ############# #
#   #   #     # #   # #     #     # #
### ##### ### ####### # ##### ### # #
# #       # #  A  #   #       #   # #
# ######### ##### # ####### ### ### #
#               ###       # # # #   #
# ### ### ####### ####### # # # # ###
# # # #   #     #B#   #   # # #   # #
# # # ##### ### # # # # ### # ##### #
#   #         #     #   #           #
#####################################}
# Maze 3 should FAIL

describe "Maze" do
  
  context "when being initialized" do
    
    before(:each) do
      @maze = Maze.new(MAZE1)
    end
    
    it "should take a string as a parameter" do
    end
    
    it "should have a method called parse" do
      @maze.should respond_to(:parse)
    end
    
    it "should contain the maze as an array" do
      @maze.should respond_to(:maze)
      @maze.maze.should be_kind_of(Array)
    end
    
    it "should be a todimentional array" do
      @maze.maze[0].should respond_to("[]")
    end
  end
  
  context "to rule out single dead ends" do
    
    before(:each) do
      @maze = Maze.new(MAZE1)
    end
    
    it "should fill in the first dead end" do
      @maze.fill_if_dead_end?(1,1)
      @maze.maze[1][1].should match("#")
    end
    it "should fill in an opposite dead end" do
      @maze.fill_if_dead_end?(3,3)
      @maze.maze[3][3].should match("#")
    end

  end
  
  context "to find all first-level dead ends" do
    
    before(:each) do
      @maze = Maze.new(MAZE1)
    end
    
    it "should call a method to loop through all characters" do
      @maze.find_and_fill_dead_ends
    end
    
    it "should fill in dead ends" do
      @maze.find_and_fill_dead_ends
      @maze.maze[1][1].should match("#")
      @maze.maze[3][3].should match("#")
    end
    
    it "should pass the koordinates on to fill_if_dead_end?" do
      @maze.should_receive(:fill_if_dead_end?).exactly(494).times
      @maze.find_and_fill_dead_ends
    end
    
  end
    
  context "to find start and ending points" do
    
    before(:each) do
      @maze1 = Maze.new(MAZE1)
      @maze2 = Maze.new(MAZE2)
    end
    
    it "should find the starting-point" do
      @maze1.find_symbol("A").should eql([1,13])
    end
    
    it "should find starting point of other mazes as well" do
      @maze2.find_symbol("A").should eql([4,7])
    end
    
    it "should find the end point of both mazes" do
      @maze1.find_symbol("B").should eql([7,23])
      @maze2.find_symbol("B").should eql([11,35])
    end
    
  end
  
  context "to verify that both a start and end-point are on the solvable path" do
    
    before(:each) do
      @maze1 = Maze.new(MAZE1)
    end
    
    it "start should have a blank neighbour after being saved" do
      @maze1.solve
      @maze1.find_symbol("A").should eql([1,13])
      @maze1.maze[1][14].should eql(" ")
    end
    
    it "should check to see if both start and finish is on the path" do
      @maze1.symbol_is_on_path?("A").should be_true
      @maze1.symbol_is_on_path?("B").should be_true
    end
    
    it "should be solvable if both A and B is on the path" do
      @maze1.solvable?.should be_true
    end
    
  end
  
  context "valid mazes" do
    
    it "should work" do
      Maze.new(MAZE1).solvable?.should be_true
      Maze.new(MAZE2).solvable?.should be_true
    end
    
    it "should return number of steps to end of maze" do
      Maze.new(MAZE1).steps.should eql(44)
      Maze.new(MAZE2).steps.should eql(75)      
    end
  end
  
  context "invalid mazes" do
        
    it "should be unsolvable" do
      Maze.new(MAZE3).solvable?.should be_false    
    end
    
    it "should return 0 steps for invalid mazes" do
      Maze.new(MAZE3).steps.should eql(0)
    end
    
  end
  
end