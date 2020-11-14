%%%-------------------------------------------------------------------
%%% @author Daagi Saber
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. avr. 2019 11:24
%%%-------------------------------------------------------------------
-module(user_controller).
-author("Daagi Saber").
%% API
-export([create/2,update/3,findByName/1,findById/1,delete/1]).

create(Name,Age) ->
  case init_app:start_connection() of
    {ok, Connection} ->
      Created_at = lib:date_to_string(erlang:localtime()),
      mc_worker_api:insert(Connection, <<"user">>, #{
        <<"first_name">> => Name,
        <<"created_at">> => Created_at,
        <<"updated_at">> => Created_at,
        <<"age">> => Age } );
    _->
      {error_conx}
  end.



update(Id,Name,Age)->
  case init_app:start_connection() of
    {ok, Connection} ->
      Id_user = list_to_binary(Id) ,
      Updated_at = lib:date_to_string(erlang:localtime()),
  Command = #{<<"$set">> => #{
    <<"first_name">> => Name,
    <<"updated_at">> => Updated_at,
    <<"age">> => Age
  }},
  mc_worker_api:update(Connection,  <<"user">> , #{<<"_id">> => lib:binary_string_to_objectid(Id_user) }, Command) ;
    _->
      {error_conx}
  end.



delete(Id)->
  case init_app:start_connection() of
    {ok, Connection} ->
      Id_user = list_to_binary(Id) ,
      mc_worker_api:delete(Connection, <<"user">>, #{<<"_id">> => lib:binary_string_to_objectid(Id_user) } );
    _->
      {error_conx}
  end.


findByName(Name)->
  case init_app:start_connection() of
    {ok, Connection} ->
    {ok, Cursor} = mc_worker_api:find(Connection, <<"user">> , #{<<"first_name">> => Name} ),
    user:display_user_list(Cursor,[id, first_name , age]);
    _->
      {error_conx}
  end.


findById(Id)->
  case init_app:start_connection() of
    {ok, Connection} ->
      Id_user = list_to_binary(Id) ,
      List = mc_worker_api:find_one(Connection, <<"user">>, #{	<<"_id">> =>  lib:binary_string_to_objectid(Id_user)  }),
      Encoded = bson_binary:put_document(List),
      {Decoded, <<>>} = bson_binary:get_document(Encoded),
      user:display_user_object(Decoded, [ id ,first_name , age]);
    _->
      {error_conx}
  end.






