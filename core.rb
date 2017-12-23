require_relative "types"

def concat(a)
  na = Array.new()
  a.each do |item|
    if item.is_a? Array
      na.concat(concat(item))
    else
      na.push(item)
    end
  end
  return na
end

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
  :/ => lambda {|a,b| a / b},
  :slurp => lambda {|a| File.read(a)},
  :atom => lambda {|a| Atom.new(a)},
  :atom? => lambda {|a| a.is_a? Atom},
  :deref => lambda {|a| a.val},
  :reset! => lambda {|a, val| a.val = val; val},
  :swap! => lambda {|*a| a[0].val = a[1][*[a[0].val].concat(a.drop(2))]},
  :cons => lambda {|a, b| Array.new(b.clone.insert(0, a))},
  :concat => lambda {|*a| return concat(a)}
}