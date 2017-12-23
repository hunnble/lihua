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

  def test_do
    assert_equal @tokenizer.eval(@tokenizer.read_str("(do (def! a 6) 7 (+ a 8))")), 14
    assert_equal @tokenizer.eval(@tokenizer.read_str("a")), 6
  end

  def test_if
    assert_equal @tokenizer.eval(@tokenizer.read_str("(if true 7 8)")), 7
    assert_equal @tokenizer.eval(@tokenizer.read_str("(if false 7 8)")), 8
    assert_equal @tokenizer.eval(@tokenizer.read_str("(if true (+ 1 7) (+ 1 8))")), 8
    assert_equal @tokenizer.eval(@tokenizer.read_str("(if false (+ 1 7) (+ 1 8))")), 9
    assert_equal @tokenizer.eval(@tokenizer.read_str("(if nil 7 8)")), 8
    assert_equal @tokenizer.eval(@tokenizer.read_str("(if 0 7 8)")), 7
    assert_equal @tokenizer.eval(@tokenizer.read_str("(if "" 7 8)")), 8
    assert_equal @tokenizer.eval(@tokenizer.read_str("(if true (+ 1 7))")), 8
    assert_nil @tokenizer.eval(@tokenizer.read_str("(if false (+ 1 7))"))
    assert_equal @tokenizer.eval(@tokenizer.read_str("(if nil 8 7)")), 7
  end

  def test_fn
    assert_equal @tokenizer.eval(@tokenizer.read_str("((fn* [a] a) 7)")), 7
    assert_equal @tokenizer.eval(@tokenizer.read_str("((fn* [a] (+ a 1)) 10)")), 11
    assert_equal @tokenizer.eval(@tokenizer.read_str("((fn* [a b] (+ a b)) 2 3)")), 5
  end

  def test_tco
    @tokenizer.eval(@tokenizer.read_str("(def! sum-to (fn* (n) (if (= n 0) 0 (+ n (sum-to (- n 1))))))"))
    @tokenizer.eval(@tokenizer.read_str("(def! sum2 (fn* (n acc) (if (= n 0) acc (sum2 (- n 1) (+ n acc)))))"))
    assert_equal @tokenizer.eval(@tokenizer.read_str("(sum-to 10)")), 55
    assert_equal @tokenizer.eval(@tokenizer.read_str("(sum2 10 0)")), 55
    @tokenizer.eval(@tokenizer.read_str("(def! foo (fn* (n) (if (= n 0) 0 (bar (- n 1)))))"))
    @tokenizer.eval(@tokenizer.read_str("(def! bar (fn* (n) (if (= n 0) 0 (foo (- n 1)))))"))
    assert_equal @tokenizer.eval(@tokenizer.read_str("(foo 10000)")), 0
    assert_equal @tokenizer.eval(@tokenizer.read_str("(do (do 1 2))")), 2
  end

  def test_atom
    @tokenizer.eval(@tokenizer.read_str("(def! a (atom 2))"))
    assert_equal @tokenizer.eval(@tokenizer.read_str("(atom? a)")), true
    assert_equal @tokenizer.eval(@tokenizer.read_str("(atom? 1)")), false
    assert_equal @tokenizer.eval(@tokenizer.read_str("(deref a)")), 2
    assert_equal @tokenizer.eval(@tokenizer.read_str("(reset! a 3)")), 3
    assert_equal @tokenizer.eval(@tokenizer.read_str("(deref a)")), 3
    assert_equal @tokenizer.eval(@tokenizer.read_str("(swap! a (fn* (a) a))")), 3
  end

  def test_quote
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quote 7)")), 7
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quote (1 2 3))")), [1, 2, 3]
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quasiquote 7)")), 7
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quasiquote (1 2 3))")), [1, 2, 3]
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quasiquote nil)")), :nil
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quasiquote (unquote 7))")), 7
    @tokenizer.eval(@tokenizer.read_str("(def! a 8)"))
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quasiquote a)")), :a
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quasiquote (unquote a))")), 8
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quasiquote (1 a 3))")), [1, :a, 3]
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quasiquote (1 (unquote a) 3))")), [1, 8, 3]
    @tokenizer.eval(@tokenizer.read_str("(def! b (quote (1 2 3)))"))
    assert_equal @tokenizer.eval(@tokenizer.read_str("(quasiquote (1 (splice-unquote b) 3))")), [1, 1, 2, 3, 3]
  end
end