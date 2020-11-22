#!/bin/sh


if [ -d "ebin" ]; then
    rm -r ebin
fi

if [ ! -d "ebin" ]; then
    mkdir ebin
    chmod 777 ebin
fi

## compile Utils
make -C lib/mongodb
cp -a lib/mongodb/ebin/.  ./ebin/
cp -a lib/mongodb/deps/bson/ebin/.  ./ebin/
cp -a lib/mongodb/deps/pbkdf2/ebin/.  ./ebin/
cp -a lib/mongodb/deps/poolboy/ebin/.  ./ebin/

## Compile Reository
compile_app()
{
for file in `find ./App/ -type f -path '*.erl'`;
do
erlc -o ebin ${file}
done
}
compile_app
