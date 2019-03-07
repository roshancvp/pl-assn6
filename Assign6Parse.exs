
defmodule Main do
    def desugar() do
        # extracts variable IDs and values
        # creates a function application
        #Appc{fun: %LamC{args: [ids...], body: parse(List.last(exp))},
        #     args: [vals...]}
    end
    
    def parse(exp) do
        cond do
            is_number(exp) ->
                %NumC{n: exp}
            is_binary(exp) ->
                %StrC{s: exp}
            is_atom(exp) ->
                %IdC{s: exp}
            length(exp) == 4 and
            List.first(exp) == :if ->
                %IfC{cond: parse(Enum.at(exp, 1)), then: parse(Enum.at(exp, 2)), else: parse(Enum.at(exp, 3))}
            length(exp) == 3 and
            List.first(exp) == :lam ->
                %LamC{args: Enum.at(exp, 1), body: Foo.parse(Enum.at(exp, 2))}
            List.first(exp) == :var ->
                desugar()
            true ->
                cond do
                    List.first(exp) == :lam or
                    List.first(exp) == :if or
                    is_number(List.first(exp)) ->
                        "ZHRL: Incorrect number of arguments..."
                    true ->
                        %AppC{fun: parse(Enum.at(exp, 0)), args: List.delete_at(exp, 0)}
                end
        end
    end
end
ExUnit.start

defmodule ParserTest do
    use ExUnit.Case
    
    test "Parse Tests" do
        assert Main.parse([:if, 56, [:x]]) == "ZHRL: Incorrect number of arguments..."
        assert Main.parse([:var, [:x, :=, 5], 10]) == "Not implemented yet..."
        assert Main.parse([:lam, [:x], 40]) == %LamC{args: [:x], body: %NumC{n: 40}}
        assert Main.parse(10) == %NumC{n: 10}
        assert Main.parse(12.3) == %NumC{n: 12.3}
        assert Main.parse(-1) == %NumC{n: -1}
        assert Main.parse("hello world") == %StrC{s: "hello world"}
        assert Main.parse("") == %StrC{s: ""}
        assert Main.parse(:*) == %IdC{s: :*}
        assert Main.parse(:x) == %IdC{s: :x}
        assert Main.parse([5]) == "ZHRL: Incorrect number of arguments..."
        assert Main.parse([:foo]) == %AppC{fun: %IdC{s: :foo}, args: []}
        assert Main.parse([:bar, 5, "hello"]) == %AppC{fun: %IdC{s: :bar}, args: [5, "hello"]}
        assert Main.parse([:lam, [:a, :b, :c], [:foo]]) ==
            %LamC{args: [:a, :b, :c], body: %AppC{fun: %IdC{s: :foo}, args: []}}
        assert Main.parse([:if, :true, 10, "ten"]) == %IfC{cond: %IdC{s: :true}, then: %NumC{n: 10}, else: %StrC{s: "ten"}}
    end
end
