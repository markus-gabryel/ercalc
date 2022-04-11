-module(calc).
-export([
	 addition/0,
	 subtraction/0,
	 multiplication/0,
	 division/0,

	 cls/0,
	 listen/4,
	 start/0
]).

addition() ->
	io:format("addition: started~n"),
	receive
		{From, X, Y} ->
			io:format("addition: receive ~p and ~p from ~p~n", [X, Y, From]),
			From ! {result, X + Y},
			addition()
	end.

subtraction() ->
	io:format("subtraction: started~n"),
	receive
		{From, X, Y} ->
			io:format("subtraction: receive ~p and ~p from ~p~n", [X, Y, From]),
			From ! {result, X - Y},
			subtraction()
	end.

multiplication() ->
	io:format("multiplication: started~n"),
	receive
		{From, X, Y} ->
			io:format("multiplication: receive ~p and ~p from ~p~n", [X, Y, From]),
			From ! {result, X * Y},
			multiplication()
	end.

division() ->
	io:format("division: started~n"),
	receive
		{From, X, Y} ->
			io:format("division: receive ~p and ~p from ~p~n", [X, Y, From]),
			From ! {result, X / Y},
			division()
	end.

%% ----------------------------------------------------------------------------

cls() -> io:format("\e[H\e[J").

listen(AddPid, SubPid, MulPid, DivPid) ->
	receive
		{result, Value} ->
			io:format("= ~p~n", [Value]);

		{'+', X, Y} ->
			AddPid ! {self(), X, Y},
			listen(AddPid, SubPid, MulPid, DivPid);
		{'-', X, Y} ->
			SubPid ! {self(), X, Y},
			listen(AddPid, SubPid, MulPid, DivPid);
		{'*', X, Y} ->
			MulPid ! {self(), X, Y},
			listen(AddPid, SubPid, MulPid, DivPid);
		{'/', X, Y} ->
			DivPid ! {self(), X, Y},
			listen(AddPid, SubPid, MulPid, DivPid)
	end.

start() ->
	AddPid	= spawn(calc, addition, []),
	SubPid	= spawn(calc, subtraction, []),
	MulPid	= spawn(calc, multiplication, []),
	DivPid	= spawn(calc, division, []),
	spawn(calc, listen, [AddPid, SubPid, MulPid, DivPid]).

