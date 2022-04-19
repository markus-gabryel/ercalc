-module(calc).
-export([
	 addition/0,
	 subtraction/0,
	 multiplication/0,
	 division/0,

	 split/1,
	 evaluate/1,
	 interpret/1,
	 compute/1,
	 start/0,
	 cls/0
]).

%% ----------------------------------------------------------------------------

addition() ->
	io:format("addition: (re)started~n"),
	receive
		{From, X, Y} ->
			Result = X + Y,
			io:format("addition: from ~p: ~p + ~p = ~p~n",
				  [From, X, Y, Result]),
			From ! {result, Result},
			addition()
	end.

subtraction() ->
	io:format("subtraction: (re)started~n"),
	receive
		{From, X, Y} ->
			Result = X - Y,
			io:format("subtraction: from ~p: ~p - ~p = ~p~n",
				  [From, X, Y, Result]),
			From ! {result, Result},
			subtraction()
	end.

multiplication() ->
	io:format("multiplication: (re)started~n"),
	receive
		{From, X, Y} ->
			Result = X * Y,
			io:format("multiplication: from ~p: ~p * ~p = ~p~n",
				  [From, X, Y, Result]),
			From ! {result, Result},
			multiplication()
	end.

division() ->
	io:format("division: (re)started~n"),
	receive
		{From, X, Y} ->
			Result = X / Y,
			io:format("division: from ~p: ~p / ~p = ~p~n",
				  [From, X, Y, Result]),
			From ! {result, Result},
			division()
	end.

%% ----------------------------------------------------------------------------

split(Expression) -> split(Expression, []).

split([], List) -> lists:reverse(List);

split([Current | Rest], List) when Current >= $0 , Current =< $9 ->
	{Value, _} = string:to_integer([Current]),
	split(Rest, List, Value);

split([Current | Rest], []) ->
	if
		Current == $  ->
			split(Rest, []);

		Current == $+ ; Current == $- ; Current == $* ; Current == $/ ->
			Operator = list_to_atom([Current]),
			split(Rest, [Operator, 0])
	end;

split([Current | Rest], List) ->
	if
		Current == $  ->
			split(Rest, List);

		Current == $+ ; Current == $- ; Current == $* ; Current == $/ ->
			Operator = list_to_atom([Current]),
			split(Rest, [Operator | List])
	end.

split([], List, Buffer) -> split([], [Buffer | List]);

split([Current | Rest], List, Buffer) when Current >= $0 , Current =< $9 ->
	{Value, _} = string:to_integer([Current]),
	split(Rest, List, Buffer * 10 + Value);

split(Expression, List, Buffer) -> split(Expression, [Buffer | List]).

%% ----------------------------------------------------------------------------

evaluate(X) when is_number(X) -> 0;
evaluate(X) when X == '+' ; X == '-' -> 1;
evaluate(X) when X == '*' ; X == '/' -> 2.

%% ----------------------------------------------------------------------------

interpret([X, Operator, Y | Rest]) ->
	interpret({Operator, X, Y}, Rest).

interpret({Root, X, Y}, [Operator, Z | Rest]) ->
	NeedsRotate = evaluate(Operator) =< evaluate(Root),
	if
		NeedsRotate ->
			interpret({Operator, {Root, X, Y}, Z}, Rest);
		true ->
			interpret({Root, X, {Operator, Y, Z}}, Rest)
	end;

interpret(Tree, []) -> Tree.

%% ----------------------------------------------------------------------------

compute(Expression) when is_integer(Expression) ; is_float(Expression) ->
	Expression;

compute(Expression) when is_tuple(Expression) ->
	case Expression of
		{'+', X, Y} ->
			addition ! {self(), compute(X), compute(Y)};
		{'-', X, Y} ->
			subtraction ! {self(), compute(X), compute(Y)};
		{'*', X, Y} ->
			multiplication ! {self(), compute(X), compute(Y)};
		{'/', X, Y} ->
			division ! {self(), compute(X), compute(Y)}
	end,

	receive
		{result, Value} ->
			Value
	end;

compute(Expression) -> compute(interpret(split(Expression))).

%% ----------------------------------------------------------------------------

start() ->
	register(addition, spawn(calc, addition, [])),
	register(subtraction, spawn(calc, subtraction, [])),
	register(multiplication, spawn(calc, multiplication, [])),
	register(division, spawn(calc, division, [])).

cls() -> io:format("\e[H\e[J").
