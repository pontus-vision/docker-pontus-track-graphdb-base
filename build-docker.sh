#!/bin/bash

set -e 
DIR="$( cd "$(dirname "$0")" ; pwd -P )"

cd $DIR/orientdb
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-odb

cd $DIR/base
docker build --rm . -t pontusvisiongdpr/pontus-track-graphdb-base

cd $DIR/full-graphdb-nifi
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-nifi

cd $DIR/full-graphdb-nifi-pt
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-nifi-pt

docker push pontusvisiongdpr/pontus-track-graphdb-nifi-pt
docker push pontusvisiongdpr/pontus-track-graphdb-nifi
docker push pontusvisiongdpr/pontus-track-graphdb-base

#cd $DIR/full-graphdb-gui
#docker build --rm . -t pontusvisiongdpr/pontus-track-graphdb-gui
#docker push pontusvisiongdpr/pontus-track-graphdb-gui


