require_relative "test_helper"

class MultiRangeTest < MiniTest::Test
  def test_init
    assert_equal [], MultiRange.new().to_ranges
    assert_equal [], MultiRange.new(2..2).to_ranges
    assert_equal [2..3], MultiRange.new(2..3).to_ranges
    assert_equal [2..4], MultiRange.new(2..3, 3..4).to_ranges
  end

  def test_infinities
    assert_equal [[2,4]], MultiRange.new(2..3, 3..4).to_list
    assert_equal [[2,4]], MultiRange.new([2,3], [3,4] ).to_list
    assert_equal [[2,nil]], MultiRange.new([2,3], [3,nil] ).to_list
    assert_equal [[2,nil]], MultiRange.new([2,nil], [3,4] ).to_list
    assert_equal [[nil,4]], MultiRange.new([nil,3], [3,4] ).to_list
    assert_equal [[nil,4]], MultiRange.new([2,4], [nil,4] ).to_list
    assert_equal [[nil,2], [4,nil]], MultiRange.new([nil,2], [4,nil]).to_list
    assert_equal [[nil,nil]], MultiRange.new([nil,4], [2,nil]).to_list
  end

  def test_errors
    # Not sure if this is sensible or just make it empty
    assert_raises(ArgumentError) do
      MultiRange.new(3..2)
    end

    assert_raises(ArgumentError) do
      MultiRange.new("omg")
    end
  end

  def test_or
    a = MultiRange.new(1..3, 5..6)
    b = MultiRange.new(2..5, 7..9)
    assert_equal MultiRange.new(1..6, 7..9), (a|b)
    assert_equal MultiRange.new(1..6, 7..9), (a+b)
  end

  def test_and
    a = MultiRange.new(1..3, 5..6)
    b = MultiRange.new(2..5, 7..9)
    assert_equal MultiRange.new(2..3), (a&b)
  end

  def test_sub
    a = MultiRange.new(1..3, 5..6)
    b = MultiRange.new(2..5, 7..9)
    assert_equal MultiRange.new(1..2, 5..6), (a-b)
    assert_equal MultiRange.new(3..5, 7..9), (b-a)
  end

  def test_eq
    assert_equal MultiRange.new(1..10), (1..10)
    refute_equal MultiRange.new(1..10), (1...10)
    assert_equal MultiRange.new(1..10), (1...11)
    assert_equal MultiRange.new(1...10), (1..9)
  end

  def test_empty
    assert_equal true, MultiRange.new.empty?
    assert_equal false, MultiRange.new(1..10).empty?
  end

  def test_to_s
    assert_equal MultiRange.new(1..10).to_s, "1..10"
    assert_equal MultiRange.new(1..10).inspect, "MultiRange.new(1..10)"
    assert_equal MultiRange.new(1..10, 20..30).to_s, "1..10 20..30"
    assert_equal MultiRange.new(1..10, 20..30).inspect, "MultiRange.new(1..10, 20..30)"
  end
end
