#!/bin/sh
#erl -pa ebin  -sname Daagi Saber -run service
erl -pa ebin  -sname Daagi Saber@localhost -run init_app -run config_server