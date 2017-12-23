def is_pair?(obj)
  # print obj
  # print "\n"
  # print obj.is_a?(Array) && obj.size() > 0
  # print "\n"
  return obj.is_a?(Array) && obj.size() > 0
end

def quasiquote(ast)
  if not is_pair?(ast)
    return Array.new [:quote, ast]
  elsif ast[0] == :unquote
    return ast[1]
  elsif is_pair?(ast[0]) && ast[0][0] == :"splice-unquote"
    return Array.new [:concat, ast[0][1], quasiquote(ast.drop(1))]
  else
    return Array.new [:cons, quasiquote(ast[0]), quasiquote(ast.drop(1))]
  end
end
