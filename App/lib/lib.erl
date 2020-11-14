%%%-------------------------------------------------------------------
%%% @author Daagi Saber
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. avr. 2019 11:29
%%%-------------------------------------------------------------------
-module(lib).
-author("Daagi Saber").

%% API
-export([binary_string_to_objectid/1,objectid_to_binary_string/1,date_to_string/1,decode_url/1]).





date_to_string({{Y, Mo, D}, {H, Mi, S}}) ->
  lists:flatten(io_lib:format("~B-~2..0B-~2..0B ~2..0B:~2..0B:~2..0B", [Y, Mo, D, H, Mi, S])).



%%This method is used to generate ObjectId from binary string.
binary_string_to_objectid(BinaryString) ->
  binary_string_to_objectid(BinaryString, []).

binary_string_to_objectid(<<>>, Result) ->
  {list_to_binary(lists:reverse(Result))};
binary_string_to_objectid(<<BS:2/binary, Bin/binary>>, Result) ->
  binary_string_to_objectid(Bin, [erlang:binary_to_integer(BS, 16)|Result]).

%%This method is used to generate binary string from objectid.
objectid_to_binary_string({Id}) ->
  objectid_to_binary_string(Id, []).

objectid_to_binary_string(<<>>, Result) ->
  list_to_binary(lists:reverse(Result));
objectid_to_binary_string(<<Hex:8, Bin/binary>>, Result) ->
  StringList1 = erlang:integer_to_list(Hex, 16),
  StringList2 = case erlang:length(StringList1) of
                  1 ->
                    ["0"|StringList1];
                  _ ->
                    StringList1
                end,
  objectid_to_binary_string(Bin, [StringList2|Result]).




decode_url(ArgList) ->
  decode_url(ArgList, dict:new()).

decode_url([H|T], Acc) ->
  case string:chr(H, $=) of
    0 ->
      decode_url(T, dict:store(H, undefined, Acc));
    Sep ->
      Name = string:substr(H, 1, Sep - 1),
      Value = string:substr(H, Sep + 1),
      decode_url(T, dict:store(Name, Value, Acc))
  end;
decode_url([], Acc) ->
  Acc.


