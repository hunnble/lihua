class Env
  def initialize
    @repl_env = Hash.new(
      "+" => lambda { |a, b|  a + b },
      "-" => lambda { |a, b|  a - b },
      "*" => lambda { |a, b|  a * b },
      "/" => lambda { |a, b|  a / b }
    )
  end
end