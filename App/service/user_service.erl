%%%-------------------------------------------------------------------
%%% @author Daagi Saber
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. avr. 2019 11:24
%%%-------------------------------------------------------------------
-module(user_service).
-author("Daagi Saber").

%% API
-export([do/1,findUserList/1,updateUser/3]).
-include_lib("inets/include/httpd.hrl").

post_methode(URL) ->
  RequestUri = URL#mod.request_uri,
  case string:chr(RequestUri, $/) of
    1 ->
      Function = string:substr(RequestUri, 2),
      Args = URL#mod.entity_body,
      %ArgList = httpd:parse_query(Args),
      ArgList = uri_string:dissect_query(Args),
      ArgDict = dict:from_list(ArgList),
      io:format("arg = ~p ~n",[ArgList]),
      if  ArgDict =:= []->
        io:format("vide");
        true ->
          io:format("non vide")
      end ,
      {ok, {Function, ArgDict}};
    _ ->
      {error}
  end.


get_methode(URL) ->
  RequestUri = URL#mod.request_uri,
  case string:chr(RequestUri, $/) of
    1 ->
      io:format("1"),
      Request = string:substr(RequestUri, 2),
      case string:chr(Request, $?) of
        0 ->
          {ok, {Request, []}};
        Sep ->
          Function = string:substr(Request, 1, Sep - 1),
          Args = string:substr(Request, Sep + 1),
          ArgList = string:tokens(Args, "&"),
          ArgDict = lib:decode_url(ArgList) ,
          {ok, {Function, ArgDict}}
      end;
    _ ->
      {error}
  end.



do(URL)->
  case URL#mod.method of
    "POST" ->
      io:format("Methode Post"),
      case post_methode(URL) of
        {ok, {Function, ArgDict}} ->
              call_methode_with_post(Function, ArgDict);
              _ -> {proceed, [{response, {500, "Bad request."}}]}
      end ;
    "GET" ->
      io:format("Methode Get"),
      case get_methode(URL) of
        {ok, {Function, ArgDict}} ->
            call_methode_with_get(Function, ArgDict);
            _ -> {proceed, [{response, {500, "Bad request"}}]}
      end;
    "PUT" ->
      io:format("Methode PUT"),
      case get_methode(URL) of
        {ok, {Function, ArgDict}} ->
          call_methode_with_put(Function, ArgDict);
        _ -> {proceed, [{response, {500, "Bad request"}}]}
      end;
    _->
      {proceed, [{response, {500, "Bad Method"}}]}

end.

call_methode_with_post(Function, Args) ->
  try
    Resp = build_post(Function, Args),
    {proceed, [{response, {200, lists:flatten(json:encode(Resp))}}]}
  catch
    _:_ ->
    {proceed, [{response, {500, "Server not found"}}]}
  end.

call_methode_with_get(Function, Args) ->
  try
    Resp = build_get(Function, Args),
    {proceed, [{response, {200, lists:flatten(json:encode(Resp))}}]}
  catch
    _:_ ->
      {proceed, [{response, {500, "Server not found"}}]}
  end.


call_methode_with_put(Function, Args) ->
  try
    Resp = build_put(Function, Args),
    {proceed, [{response, {200, lists:flatten(json:encode(Resp))}}]}
  catch
    _:_ ->
      {proceed, [{response, {500, "Server not found"}}]}
  end.


build_post(Function, Args) ->
  try
    case Function of
        "user" ->
            Name = dict:fetch("first_name", Args),
            Age = dict:fetch("age",Args),
            {struct, [{Function, createUser(Name,Age)}]};
          _ ->
            {struct, [{Function, {struct, [{"status", "error"}, {"reason", "Bad Request"}]}}]}
    end
  catch
    _:_ ->
      {struct, [{Function, {struct, [{"status", "error"}, {"reason", "Method Not Allowed"}]}}]}
  end.


build_put(Function, Args) ->
  try
    case Function of
      "user" ->
        Id = dict:fetch("id", Args),
        Name = dict:fetch("first_name", Args),
        Age = dict:fetch("age",Args),
        {struct, [{Function, updateUser(Id,Name,Age)}]};

      _ ->
        {struct, [{Function, {struct, [{"status", "error"}, {"reason", "Bad Request"}]}}]}
    end
  catch
    _:_ ->
      {struct, [{Function, {struct, [{"status", "error"}, {"reason", "Method Not Allowed"}]}}]}
  end.

build_get(Function, Args) ->
  try
    case Function of
      "users" ->
        Name = dict:fetch("first_name", Args),
        {struct, [{Function, findUserList(Name)}]};
      "user" ->
         Id = dict:fetch("id", Args),
         {struct, [{Function,  findUser(Id)}]};
      _ ->
        {struct, [{Function, {struct, [{"status", "error"}, {"reason", "Bad Request"}]}}]}
    end
  catch
    _:_ ->
      {struct, [{Function, {struct, [{"status", "error"}, {"reason", "Method Not Allowed"}]}}]}
  end.


findUser(Id)->
  case user_controller:findById(Id) of
     User ->
      {struct, [{"status", "ok"}, {"user", user:object_to_json(User)}]}
    end.


findUserList(Name)->
  case user_controller:findByName(Name) of
     UserList ->
      {struct, [{"status", "ok"}, {"users", user:list_to_json(UserList)}]}
    end.

createUser(Name,Age) ->
  case user_controller:create(Name,Age) of
     List ->
      {struct, [{"status", "ok"}, {"user", user:object_to_json(List)}]}
    end.


updateUser(Id,Name,Age) ->
  case user_controller:update(Id,Name,Age) of
    List ->
      {struct, [{"status", "ok"}, {"user", user:object_to_json(List)}]}
  end.