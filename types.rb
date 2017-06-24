class Exception < StandardError
  attr_reader :e

  def initialize(e)
    @e = e
  end
end

class String
  attr_accessor :str

  def initialize(str)
    @str = str
  end
end

class Integer
  attr_accessor :val

  def initialize(val)
    @val = val
  end
end
