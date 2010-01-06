require 'test/unit'
require 'grid'

GRID = %{
####
#AB#
####
}.strip

class GridTest < Test::Unit::TestCase
  def setup
    @grid = Grid.new(GRID)
  end
  
  def test_width
    assert_equal 4, @grid.width
  end
  
  def test_height
    assert_equal 3, @grid.height
  end
  
  def test_get_node
    assert_equal 1, @grid.node(1, 0).x
    assert_equal 2, @grid.node(0, 2).y
  end
  
  def test_get_walkable_nodes
    assert_equal 1, @grid.walkable_nodes.first.x
    assert_equal 1, @grid.walkable_nodes.first.y
    
    assert_equal 2, @grid.walkable_nodes.last.x
    assert_equal 1, @grid.walkable_nodes.last.y
  end
  
  def test_get_start_node
    assert_equal 1, @grid.start_node.x
    assert_equal 1, @grid.start_node.y
  end
  
  def test_get_end_node
    assert_equal 2, @grid.end_node.x
    assert_equal 1, @grid.end_node.y
  end
  
  def test_get_adjecents
    node = @grid.node(0, 1)
    assert_equal 3, @grid.adjecents(node).length
    
    node = @grid.node(1, 1)
    assert_equal 4, @grid.adjecents(node).length
  end
  
  def test_to_str
    assert_equal @grid.to_s, GRID
  end
end