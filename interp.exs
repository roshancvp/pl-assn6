defmodule Main do

  defmodule NumC do
    # types: <integer>
    defstruct n: nil
  end

  defmodule IdC do
    # types: <atom>
    defstruct s: nil
  end

  defmodule LamC do
    # types: <list of atom>, <ExprC>
    defstruct args: [], body: nil
  end

  defmodule AppC do
    # types: <ExprC>, <list of ExprC>
    defstruct fun: nil, args: []
  end

  defmodule IfC do
    # types: <ExprC>, <ExprC>, <ExprC>
    defstruct cond: nil, then: nil, else: nil
  end

  defmodule CloV do
    # types: <list of atom>, <ExprC>, <Env>
    defstruct args: [], body: nil, env: nil
  end

  defmodule PrimV do
    # types: <function>,
    defstruct op: nil
    # def add(x, y) do
    #    fn (x, y) -> x + y end
    # end
    # def sub(x, y) do
    #   fn (x, y) -> x - y end
    # end
    # def mult(x, y) do
    #   fn (x, y) -> x * y end
    # end
    # def divide(x,y) do
    #    if y === 0 do
    #       raise "ZHRL: can't divide by zero"
    #    else
    #       div
    #    end
    # end
    # def lessthen_eq?(x, y) do
    #   fn (x, y) -> x <= y end
    # end
    # def eql?(x, y do
    #   fn (x, y) -> x == y end
    # end
  end

  def helper(env, fdArgs, appcArgs) do
    if length(fdArgs) > 0 do
      [headFd | tailFd] = fdArgs
      [headAppC | tailAppC] = appcArgs
      newMap = Map.merge(env, %{headFd => headAppC})
      helper(newMap, tailFd, tailAppC)
    end
  end

  def interp(e, env) do
    case e.__struct__ do
      NumC -> e.n
      IdC -> env[e.s]
      IfC ->
        result = interp(e.cond, env)
        if !is_boolean(result) do
          raise "ZHRL: test is not a boolean"
        else
          if result do
            interp(e.then, env)
          else
            interp(e.else, env)
          end
        end
      LamC -> %CloV{args: e.args, body: e.body, env: env}
      AppC ->
        argvals = Enum.map(e.args, fn arg -> interp(arg, env) end)
        IO.puts(interp(e.fun, env))
        case interp(e.fun, env) do
          PrimV -> e.op(argvals[0], argvals[1])
          CloV ->
            newEnv = helper(e.env, e.args, e.env)
            interp(e.body, newEnv)
          _ -> raise "ZHRL: Invalid application syntax"
        end
      _ ->
        "Didn't Match"
    end
  end
  def test() do
    topEnv = %{
      :true => true,
      :false => false,
      :+ => %PrimV{op: fn (x,y) -> x+y end}
      :- => %PrimV{op: fn (x,y) -> x+y end}
      :* => %PrimV{op: fn (x,y) -> x+y end}
      :/ => %PrimV{op: fn (x,y) -> x+y end}
    }

    assert(interp(%NumC{n: 2}, %{}), 2)
    assert(interp(%IdC{s: :x}, %{:x => 5}), 5)
    assert(interp(%LamC{args: [%NumC{n: 1}], body: %AppC{}}, %{:x => 5}),
    %CloV{args: [%NumC{n: 1}], body: %AppC{}, env: %{:x => 5}})
  end

  def assert(v1, v2) do
    if v1 != v2 do
      raise "expected #{v2} but evaluated to #{v1}"
    end
  end
end
