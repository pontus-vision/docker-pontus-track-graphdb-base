#!/bin/bash

set -e 
DIR="$( cd "$(dirname "$0")" ; pwd -P )"
cd $DIR/base
docker build --rm . -t pontusvisiongdpr/pontus-track-graphdb-base

cd $DIR/full-graphdb-nifi
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-nifi

docker push pontusvisiongdpr/pontus-track-graphdb-nifi
docker push pontusvisiongdpr/pontus-track-graphdb-base

#cd $DIR/full-graphdb-gui
#docker build --rm . -t pontusvisiongdpr/pontus-track-graphdb-gui
#docker push pontusvisiongdpr/pontus-track-graphdb-gui


