-module(calc).
-export([addition/2, subtraction/2, multiplication/2, division/2, clear/0]).

addition(X, Y) ->
	X + Y.

subtraction(X, Y) ->
	X - Y.

multiplication(X, Y) ->
	X * Y.

division(X, Y) ->
	X / Y.

clear() ->
	io:format("\e[H\e[J").

