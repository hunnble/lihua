require "minitest/autorun"
require_relative "../tokenizer.rb"

class TestTokenizer < Minitest::Test
  def setup
    @tokenizer = Tokenizer.new
  end

  def test_tokenizer_empty
    assert_nil @tokenizer.read_str("")
  end

  def test_tokenizer_simple
    assert_equal @tokenizer.read_str("123"), 123
    assert_equal @tokenizer.read_str("abc"), :abc
  end

  def test_tokenizer_list
    assert_equal @tokenizer.read_str("(+ 2 3)"), [:+, 2, 3]
    assert_equal @tokenizer.read_str("(+ -2 3)"), [:+, -2, 3]
    assert_equal @tokenizer.read_str("(+ (+ 2 3) 4)"), [:+, [:+, 2, 3], 4]
  end

  def test_eval
    assert_nil @tokenizer.eval(@tokenizer.read_str(""))
    assert_equal @tokenizer.eval(@tokenizer.read_str("(+ 2 3)")), 5
    assert_equal @tokenizer.eval(@tokenizer.read_str("(- 2 3)")), -1
    assert_equal @tokenizer.eval(@tokenizer.read_str("(* 2 3)")), 6
    assert_equal @tokenizer.eval(@tokenizer.read_str("(/ 2 3)")), 2 / 3
    assert_equal @tokenizer.eval(@tokenizer.read_str("(+ (- 3 4) 3)")), 2
  end

  def test_eval_environment
    assert_equal @tokenizer.eval(@tokenizer.read_str("(def! a 6)")), 6
    assert_equal @tokenizer.eval(@tokenizer.read_str("a")), 6
    assert_equal @tokenizer.eval(@tokenizer.read_str("(def! b (+ a 2))")), 8
    assert_equal @tokenizer.eval(@tokenizer.read_str("(+ a b)")), 14
    assert_equal @tokenizer.eval(@tokenizer.read_str("(let* (c 2) c)")), 2
  end
end