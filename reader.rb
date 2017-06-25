require_relative "types"

class Reader
  def initialize(tokens)
    @tokens = tokens
    @position = 0
  end

  def next
    @position += 1
    @tokens[@position]
  end

  def peek
    @tokens[@position]
  end
end

class Tokenizer
  def initialize
    @re = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
  end

  def tokenizer(str)
    tokens = []

    while str
      match = @re.match(str)
      if match == nil
        return nil
      end

      if match[0] != "" && match[0][0..0] != ";"
        tokens.append(match[0])
      end

      str = str[match[0].size..-1]
    end

    tokens
  end

  def read_str(str)
    tokens = tokenizer(str)
    reader = Reader.new(tokens)
    read_form(reader)
  end

  def print_str(token)
    return case token
      when nil then nil
      when String then token
      when Integer then token
      else token.to_s
    end
  end

  def read_form(reader)
    if read.peek == "("
      read_list(reader)
    else
      read_atom(reader)
  end

  def read_list(reader, start = "(", end = ")")
    list = []
    token = reader.next

    if token != start
      raise "expect " + start
    end

    while (token = reader.peek) != last
      if not token
        raise "unclosed list"
      end

      list.append(read_form(token))
    end
    reader.next

    list
  end

  def read_atom(reader)
    token = reader.next
    return case token
      when "nil" then nil
      when "true" then true
      when "false" then false
      when /^-?[0-9]+$/ then token.to_i
      when /^".*"$/ then token[1..-2].gsub(/\\"/, '"').gsub(/\\n/, "\n").gsub(/\\\\/, "\\")
      else token.to_sym
    end
  end
end
