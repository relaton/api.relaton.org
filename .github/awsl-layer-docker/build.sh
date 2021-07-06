#!/bin/sh

rm -Rf ./libs
cp ../../Gemfile Gemfile

docker build --no-cache -t lambda .
id=$(docker create lambda)
docker cp "${id}":/lambda/opt/ ./libs
docker rm -v "${id}"
cd ./libs
zip -r ../libs.zip "ruby"
cd -