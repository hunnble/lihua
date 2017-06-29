class Reader
  def initialize(tokens)
    @tokens = tokens
    @position = 0
  end

  def next
    @position += 1
    @tokens[@position - 1].strip
  end

  def peek
    @tokens[@position].strip
  end
end

