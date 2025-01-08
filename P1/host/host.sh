#!/bin/sh

docker build . -t host-nplieger-ssar
docker run host-nplieger-ssar
