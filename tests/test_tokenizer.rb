require "minitest/autorun"
require_relative "../reader.rb"

class TestTokenizer < Minitest::Test
  def setup
    @tokenizer = Tokenizer.new
  end

  def test_tokenizer_empty
    assert_nil @tokenizer.read_str("")
  end

  def test_tokenizer_simple
    assert_equal @tokenizer.read_str("123"), 123
    assert_equal @tokenizer.read_str("12 3"), 123
    assert_equal @tokenizer.read_str("abc"), :abc
    assert_equal @tokenizer.read_str("ab c"), :abc
  end

  def test_tokenizer_list
    assert_equal @tokenizer.read_str("(+ 2 3)"), [:"+23"]
    assert_equal @tokenizer.read_str("(+ (+ 2 3) 4)"), [:+, [:"+23"], 4]
  end
end