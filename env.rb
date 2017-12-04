class Env
  attr_accessor :data

  def initialize(outer = nil)
    @data = {}
    @outer = outer
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