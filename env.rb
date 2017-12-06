class Env
  attr_accessor :data

  def initialize(outer = nil, binds = [], exprs = [])
    @data = {}
    @outer = outer
    binds.each_index do |i|
      if binds[i] == :"&"
        data[binds[i+1]] = exprs.drop(i)
        break
      else
        data[binds[i]] = exprs[i]
      end
    end
    return self
  end

  def set(key, val)
    @data[key] = val
    val
  end

  def find(key)
    if @data.key? key
      self
    elsif @outer
      @outer.find(key)
    else
      nil
    end
  end

  def get(key)
    env = find(key)

    raise "not found" if not env
    env.data[key]
  end
end