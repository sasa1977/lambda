Lambda
=======
Syntactic sugar for defining lambda functions with explicit scope.

# Motivation
Sometimes we need to send a simple fun as an argument of another fun, and *fn(...) -> end* feels like adding a bit of a noise. Elixir offers an &... notation to help with this, but it doesn't always work as expected:

    iex(1)> Enum.map(1..2, {&1, &1*&1})
    [{1,#Function<erl_eval.6.82930912>},{2,#Function<erl_eval.6.82930912>}]

The problem is that an &... operator turns the first parent expression into a function. In this case the second element of a tuple is turned into a fun which wraps the multiplication.

# Lambda
The Lambda module provides the %f macro which works a bit differently, making the scope which will be turned into a fun explicit:

    Enum.map(1..2, %f({&1, &1*&1}))   # [{1,1},{2,4}]
    
Anything inside %f(...) will be turned into an anonymous function. The &n references the nth parameter of the function.
Not all parameters must be named. The arity is deduced from the largest parameter reference:

    %f(&2)        # arity 2
    %f(&5 * &8)   # arity 8
    %f(2 * 3)     # arity 0
    
You can explicitly set arity:

    %f(3, 5 * &2) # arity 3
    
To use it, just add dependency to your mix file, and import Lambda in your module:

    import Lambda
    ...
    %f(...)

The syntax relies on [Elixir sigils](http://elixir-lang.org/getting_started/6.html) which means there is one caveat:

    %f(&1 * (&2 * 3))   # compiler error, the first right parenthesis terminates the macro

You can easily work around that by using another character instead of parentheses:

    %f{...}
    %f[...]
    %f`...`
    %f/.../
    etc.

The nesting works, although I wouldn't recommend it:

    IO.puts %f{&1 * %f[&1 + 1].(&2 * 3)}.(2,3)    # 20