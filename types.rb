require_relative "env"

class Function < Proc
  attr_accessor :ast
  attr_accessor :env
  attr_accessor :params
  attr_accessor :is_macro

  def initialize(ast = nil, params = nil, env = nil, &block)
    super()
    @ast = ast
    @params = params
    @env = env
    @is_macro = false
  end

  def gen_env(args)
    return Env.new(@env, @params, args)
  end
end

class Atom
  attr_accessor :val

  def initialize(val)
    @val = val
  end
end
