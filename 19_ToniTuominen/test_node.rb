require 'test/unit'
require 'node'

class NodeTest < Test::Unit::TestCase
  def test_walkable
    assert_equal true, Node.new(" ", 0, 0).walkable?
    assert_equal false, Node.new("#", 0, 0).walkable?
    assert_equal true, Node.new("A", 0, 0).walkable?
    assert_equal true, Node.new("B", 0, 0).walkable?
  end
  
  def test_start
    assert_equal true, Node.new("A", 0, 0).start?
    assert_equal false, Node.new(" ", 0, 0).start?
  end
  
  def test_end
    assert_equal true, Node.new("B", 0, 0).end?
    assert_equal false, Node.new(" ", 0, 0).end?
  end
  
  def test_f
    node = Node.new(" ", 0, 0)
    node.g = 2
    node.h = 3
    assert_equal 5, node.f
  end
  
  def test_distance_from
    a = Node.new(" ", 1, 1)
    b = Node.new(" ", 5, 4)
    assert_equal 5, a.distance_from(b)
  end
  
  def test_to_s
    assert_equal "#", Node.new("#", 0, 0).to_s
  end
end