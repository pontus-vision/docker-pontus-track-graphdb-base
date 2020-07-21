#!/bin/bash

export TAG=${TAG:-latest}
set -e 
DIR="$( cd "$(dirname "$0")" ; pwd -P )"

cd $DIR/orientdb
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-odb:${TAG}

cd $DIR/orientdb-pt
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-odb-pt:${TAG}

docker push pontusvisiongdpr/pontus-track-graphdb-odb-pt:${TAG}
docker push pontusvisiongdpr/pontus-track-graphdb-odb:${TAG}

cd $DIR/base
docker build --rm . -t pontusvisiongdpr/pontus-track-graphdb-base:${TAG}

cd $DIR/full-graphdb-nifi
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-nifi:${TAG}

cd $DIR/full-graphdb-nifi-pt
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-nifi-pt:${TAG}

docker push pontusvisiongdpr/pontus-track-graphdb-nifi-pt:${TAG}
docker push pontusvisiongdpr/pontus-track-graphdb-nifi:${TAG}
docker push pontusvisiongdpr/pontus-track-graphdb-base:${TAG}

#cd $DIR/full-graphdb-gui
#docker build --rm . -t pontusvisiongdpr/pontus-track-graphdb-gui
#docker push pontusvisiongdpr/pontus-track-graphdb-gui


