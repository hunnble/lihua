require_relative "types"

class Reader
  def initialize(tokens)
    @tokens = tokens
    @position = 0
  end

  def next
    @position += 1
    @tokens[@position - 1]
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

    i = 0
    while str.size > 0
      match = @re.match(str)
      if match == nil
        return nil
      end

      if match[0] != "" && match[0][0..0] != ";"
        tokens.push(match[0])
      end

      str = str[match[0].size..-1]
    end

    read_form(Reader.new(tokens))
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
    return case reader.peek
      when ";" then nil
      when "(" then read_list(reader)
      when ")" then raise "unexpected ')'"
      else read_atom(reader);
    end
  end

  def read_list(reader, start = "(", last = ")")
    list = []
    token = reader.next

    if token != start
      raise "expect " + start
    end

    while (token = reader.peek) != last
      if not token
        raise "unclosed list"
      end
      # puts read_form(reader)
      list.push(read_form(reader))
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

puts Tokenizer.new.tokenizer("(+ 2 3)")
