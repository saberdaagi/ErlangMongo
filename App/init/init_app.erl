%%%-------------------------------------------------------------------
%%% @author Daagi Saber
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. avr. 2019 11:23
%%%-------------------------------------------------------------------
-module(init_app).
-author("Daagi Saber").

-export([
	start/0,
	start_connection/0
]).


%% @hidden
start() ->
	application:start (bson),
	application:start (crypto),
	application:start (poolboy),
	application:start (pbkdf2),
	application:start (mongodb).


start_connection()->
 mc_worker_api:connect ([{database, <<"test">>}]).






