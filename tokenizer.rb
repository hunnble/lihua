require_relative "reader.rb"

class Tokenizer
  def initialize
    @re = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
    @default_env = {}
    @default_env[:+] = lambda { |a, b|  a + b }
    @default_env[:-] = lambda { |a, b|  a - b }
    @default_env[:*] = lambda { |a, b|  a * b }
    @default_env[:/] = lambda { |a, b|  a / b }
  end

  def tokenize(str)
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

    tokens
  end

  def read_str(str)
    return nil if str.size == 0

    tokens = tokenize(str)
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
      list.push(read_form(reader))
    end
    reader.next

    list
  end

  def read_atom(reader)
    token = reader.next
    return case token
      when nil then nil
      when "true" then true
      when "false" then false
      when /^-?[0-9]+$/ then token.to_i
      when /^".*"$/ then token[1..-2].gsub(/\\"/, '"').gsub(/\\n/, "\n").gsub(/\\\\/, "\\")
      else token.to_sym
    end
  end

  def eval_ast(ast, env = @default_env)
    return case ast
      when Symbol
        raise ast.to_s + " is not a valid operator" if not env[ast]
        env[ast]
      when Array
        ast.map {|ast_item| eval(ast_item, env)}
      else ast
    end
  end

  def eval(ast, env = @default_env)
    if not ast.is_a? Array
      return eval_ast(ast, env)
    end

    if ast.empty?
      return ast
    end

    els = eval_ast(ast, env)
    op = els[0]
    op[*els.drop(1)]
  end
end
