require 'test/unit'
require 'maze'

class MazeUnitTest < Test::Unit::TestCase
  Maze.send :public, *Maze.protected_instance_methods

  def test_input_symbols
    assert_equal true,  Maze.new("# A # B").valid?
    assert_equal true,  Maze.new("# A \nB").valid?
    assert_equal false, Maze.new("# A + B").valid?
  end

  def test_start_count
    assert_equal true,  Maze.new("B A ").valid?
    assert_equal false, Maze.new("B   ").valid?
    assert_equal false, Maze.new("B AA").valid?
  end

  def test_end_count
    assert_equal true,  Maze.new("A B ").valid?
    assert_equal false, Maze.new("A   ").valid?
    assert_equal false, Maze.new("A BB").valid?
  end

  def test_extract_waypoints
    actual_waypoints = extract_waypoints("# A\n# B")
    expected_waypoints = {[0, 1] => ' ', [0, 2] => 'A', [1, 1] => ' ', [1, 2] => 'B'}
    assert_equal expected_waypoints, actual_waypoints
  end

  def test_waypoint_spotting
    maze = Maze.new("# A\n# B")
    actual_waypoints = maze.spot_new_waypoints([0, 1], {[0, 2] => 0, [0, 1] => 1})
    expected_waypoints = [[1, 1]]
    assert_equal expected_waypoints, actual_waypoints
  end

  def test_start_position
    assert_equal [0, 2], extract_waypoints("##A\nB##").start_position
    assert_equal nil,    extract_waypoints("").start_position
  end

  def test_end_position
    assert_equal [1, 0], extract_waypoints("##A\nB##").end_position
    assert_equal nil,    extract_waypoints("").end_position
  end

  def test_solvability
    assert_equal false, Maze.new("A").solvable?
    assert_equal true,  Maze.new("#A \n#  \n  B").solvable?
  end

  def test_steps
    assert_equal 0, Maze.new("").steps
    assert_equal 0, Maze.new("A").steps
    assert_equal 0, Maze.new("A#B").steps
    assert_equal 1, Maze.new("AB").steps
    assert_equal 2, Maze.new("#A \n# B").steps
  end

  def extract_waypoints maze_string
    maze_string.extend(MazeString)
    maze_string.extract_waypoints
  end
end
