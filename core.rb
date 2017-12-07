$core_ns = {
  :list => lambda {|*a| Array.new a},
  :list? => lambda {|a| a.is_a? Array},
  :empty? => lambda {|a| a.size == 0},
  :count => lambda {|a| return 0 if a == nil; a.size},
  :"=" => lambda {|a0, a1| a0 == a1},
  :< => lambda {|a,b| a < b},
  :<= => lambda {|a,b| a <= b},
  :> => lambda {|a,b| a > b},
  :>= => lambda {|a,b| a >= b},
  :+ => lambda {|a,b| a + b},
  :- => lambda {|a,b| a - b},
  :* => lambda {|a,b| a * b},
  :/ => lambda {|a,b| a / b}
}