def is_pair?(obj)
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

def is_macro_call?(ast, env)
  return (
    ast.is_a?(Array) &&
    ast[0].is_a?(Symbol) &&
    env.find(ast[0]) &&
    env.get(ast[0]).is_a?(Function) &&
    env.get(ast[0]).is_macro
  )
end

def macroexpand(ast, env)
  while is_macro_call?(ast, env)
    func = env.get(ast[0])
    ast = func[*ast.drop(1)]
  end
  return ast
end
