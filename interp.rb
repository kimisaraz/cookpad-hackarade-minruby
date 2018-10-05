require "minruby"

# An implementation of the evaluator
def evaluate(exp, env, genv)
  # exp: A current node of AST
  # env: An environment (explained later)
  # genv: An global environment (never explained later)

  case exp[0]

  #
  ## Problem 1: Arithmetics
  #

  when "lit"
    exp[1] # return the immediate value as is

  when "+"
    evaluate(exp[1], env, genv) + evaluate(exp[2], env, genv)
  when "-"
    evaluate(exp[1], env, genv) - evaluate(exp[2], env, genv)
  when "*"
    evaluate(exp[1], env, genv) * evaluate(exp[2], env, genv)
  when "/"
    evaluate(exp[1], env, genv) / evaluate(exp[2], env, genv)
  when "%"
    evaluate(exp[1], env, genv) % evaluate(exp[2], env, genv)
  when ">"
    evaluate(exp[1], env, genv) > evaluate(exp[2], env, genv)
  when "<"
    evaluate(exp[1], env, genv) < evaluate(exp[2], env, genv)
  when "=="
    evaluate(exp[1], env, genv) == evaluate(exp[2], env, genv)

  #
  ## Problem 2: Statements and variables
  #

  when "stmts"
    # Statements: sequential evaluation of one or more expressions.
    #
    # Advice 1: Insert `pp(exp)` and observe the AST first.
    # Advice 2: Apply `evaluate` to each child of this node.
    i = 1
    res = nil
    while exp[i]
      res = evaluate(exp[i], env, genv)
      i = i + 1
    end

    res

  # The second argument of this method, `env`, is an "environement" that
  # keeps track of the values stored to variables.
  # It is a Hash object whose key is a variable name and whose value is a
  # value stored to the corresponded variable.

  when "var_ref"
    # Variable reference: lookup the value corresponded to the variable
    #
    # Advice: env[???]
    env[exp[1]]

  when "var_assign"
    # Variable assignment: store (or overwrite) the value to the environment
    #
    # Advice: env[???] = ???
    env[exp[1]] = evaluate(exp[2], env, genv)

  #
  ## Problem 3: Branchs and loops
  #

  when "if"
    # Branch.  It evaluates either exp[2] or exp[3] depending upon the
    # evaluation result of exp[1],
    #
    # Advice:
    #   if ???
    #     ???
    #   else
    #     ???
    #   end
    if evaluate(exp[1], env, genv)
      evaluate(exp[2], env, genv)
    else
      evaluate(exp[3], env, genv)
    end

  when "while"
    # Loop.
    while evaluate(exp[1], env, genv)
      evaluate(exp[2], env, genv)
    end

  #
  ## Problem 4: Function calls
  #

  when "func_call"
    # Lookup the function definition by the given function name.
    func = genv["function_definitions"][exp[1]]

    if func == nil
      # We couldn't find a user-defined function definition;
      # it should be a builtin function.
      # Dispatch upon the given function name, and do paticular tasks.
      case exp[1]
      when "require"
        require(evaluate(exp[2], env, genv))
      when "minruby_parse"
        minruby_parse(evaluate(exp[2], env, genv))
      when "minruby_load"
        minruby_load()
      when "p"
        # MinRuby's `p` method is implemented by Ruby's `p` method.
        p(evaluate(exp[2], env, genv))
      # ... Problem 4
      when "Integer"
        Integer(evaluate(exp[2], env, genv))
      when "fizzbuzz"
        if evaluate(exp[2], env, genv) % 15 == 0
          "FizzBuzz"
        elsif evaluate(exp[2], env, genv) % 3 == 0
          "Fizz"
        elsif evaluate(exp[2], env, genv) % 5 == 0
          "Buzz"
        else
          evaluate(exp[2], env, genv)
        end
      else
        raise("unknown builtin function")
      end
    else

      #
      ## Problem 5: Function definition
      #

      # (You may want to implement "func_def" first.)
      #
      # Here, we could find a user-defined function definition.
      # The variable `func` should be a value that was stored at "func_def":
      # parameter list and AST of function body.
      #
      # Function calls evaluates the AST of function body within a new scope.
      # You know, you cannot access a varible out of function.
      # Therefore, you need to create a new environment, and evaluate the
      # function body under the environment.
      #
      # Note, you can access formal parameters (*1) in function body.
      # So, the new environment must be initialized with each parameter.
      #
      # (*1) formal parameter: a variable as found in the function definition.
      # For example, `a`, `b`, and `c` are the formal parameters of
      # `def foo(a, b, c)`.

      # func_args = exp[2..-1].map { |e| evaluate(e, env, genv) }
      i = 2
      func_args = []
      while exp[i]
        elem = exp[i]
        func_args[i - 2] = evaluate(elem, env, genv)
        i = i + 1
      end

      # func_env = func["params"].zip(func_args).to_h
      func_env = {}
      j = 0
      while func_args[j]
        func_env[func["params"][j]] = func_args[j]
        j = j + 1
      end

      evaluate(func["body"], func_env, genv)
    end

  when "func_def"
    # Function definition.
    #
    # Add a new function definition to function definition list.
    # The AST of "func_def" contains function name, parameter list, and the
    # child AST of function body.
    # All you need is store them into $function_definitions.
    #
    # Advice: $function_definitions[???] = ???

    genv["function_definitions"][exp[1]] = {
      "params" => exp[2],
      "body" => exp[3],
    }


  #
  ## Problem 6: Arrays and Hashes
  #

  # You don't need advices anymore, do you?
  when "ary_new"
    # exp[1..-1].map { |e| evaluate(e, env, genv) }
    i = 1
    new_ary = []
    while exp[i]
      elem = exp[i]
      new_ary[i - 1] = evaluate(elem, env, genv)
      i = i + 1
    end

    new_ary

  when "ary_ref"
    evaluate(exp[1], env, genv)[evaluate(exp[2], env, genv)]

  when "ary_assign"
    evaluate(exp[1], env, genv)[evaluate(exp[2], env, genv)] = evaluate(exp[3], env, genv)

  when "hash_new"
    # exp[1..-1].map { |e| evaluate(e, env, genv) }.each_slice(2).to_h
    # map
    i = 1
    ary = []
    while exp[i]
      elem = exp[i]
      ary[i - 1] = evaluate(elem, env, genv)
      i = i + 1
    end

    # each_slice(2).to_h
    j = 0
    hash = {}
    while ary[j]
      hash[ary[j]] = ary[j+1]
      j = j + 2
    end

    hash

  else
    p("error")
    pp(exp)
    raise("unknown node")
  end
end

genv = {}
genv["function_definitions"] = {}
env = {}

# `minruby_load()` == `File.read(ARGV.shift)`
# `minruby_parse(str)` parses a program text given, and returns its AST
evaluate(minruby_parse(minruby_load()), env, genv)
