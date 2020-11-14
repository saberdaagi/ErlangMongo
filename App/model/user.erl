%%%-------------------------------------------------------------------
%%% @author Daagi Saber
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. avr. 2019 11:23
%%%-------------------------------------------------------------------
-module(user).
-author("Daagi Saber").

%% API
-export([display_user_list/2,display_user_object/2,list_to_json/1,object_to_json/1]).




%% iterate list Document bson
display_user_list(Cursor, List) ->
  display_user_list(Cursor, List, []).

display_user_list(Cursor, List, Acc) ->
  case mc_cursor:next(Cursor) of
    {Result} ->
      Encoded1 = bson_binary:put_document(Result),
      {Decoded1, <<>>} = bson_binary:get_document(Encoded1),
      display_user_list(Cursor, List, [display_user_object(Decoded1, List) | Acc]);
    _->lists:reverse(Acc)
  end.


%% Document bson to list
display_user_object(Cursor, List) ->
  display_user_object(Cursor, List, []).

display_user_object(Cursor, [H | T], Acc) ->
  case object(Cursor, H) of
    {ok, Prop} ->
      display_user_object(Cursor, T, [Prop | Acc]);
    _ ->
      display_user_object(Cursor, T, Acc)
  end;
display_user_object(_, _, Acc) ->
  lists:reverse(Acc).

object(Decoded, PropName) ->
  case PropName of
    id -> {ok, {id,  binary_to_list(lib:objectid_to_binary_string( bson:at(<<"_id">>,Decoded)))}};
    first_name  -> {ok, {first_name, bson:at(<<"first_name">>,Decoded)}};
    age ->{ok, {age, bson:at(<<"age">>,Decoded)}};
    created_at -> {ok, {created_at,bson:at(<<"Created_at">>,Decoded)}};
    _ -> {error, bad_object}
  end.


%%% parse list to json
list_to_json(List) ->
  list_to_json(List, []).

list_to_json([H | T], Acc) ->
  list_to_json(T, [object_to_json(H) | Acc]);
list_to_json(_, Acc) ->
  {array, lists:reverse(Acc)}.



%%% parse object to json
object_to_json(Props) ->
  object_to_json(Props, []).

object_to_json([H | T], Acc) ->
  object_to_json(T, [user_json(H) | Acc]);

object_to_json(_, Acc) ->
  {struct, lists:reverse(Acc)}.




user_json({id, Value}) -> {"id", Value};
user_json({first_name, Value}) -> {"first_name", Value};
user_json({age, Value}) -> {"age", Value}.
