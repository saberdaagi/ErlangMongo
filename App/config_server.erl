%%%-------------------------------------------------------------------
%%% @author Daagi Saber
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. avr. 2019 11:57
%%%-------------------------------------------------------------------
-module(config_server).
-author("Daagi Saber").



-export([start/0, stop/0]).

start() ->
  try
    inets:start(),
    inets:start(httpd, [{proplist_file, "App/service/config/web.config"}]),
    io:format("Web server is ready !")

  catch
    Reason ->

      {error , Reason}

  end.

%% @doc stopping daemons and clients.
stop() ->
  inets:stop().

