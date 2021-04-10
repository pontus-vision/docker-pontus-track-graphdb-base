#!/bin/bash

export TAG=${TAG:-1.13.2}
set -e 
DIR="$( cd "$(dirname "$0")" ; pwd -P )"

export DOLLAR='$'
cd $DIR/orientdb
cat $DIR/orientdb/Dockerfile.template | envsubst > $DIR/orientdb/Dockerfile
docker build  --rm  . -t pontusvisiongdpr/pontus-track-graphdb-odb:${TAG}

cd $DIR/orientdb-pt
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-odb-pt:${TAG}

cat $DIR/base/Dockerfile.template | envsubst > $DIR/base/Dockerfile
cd $DIR/base
docker build --rm . -t pontusvisiongdpr/pontus-track-graphdb-base:${TAG}

cd $DIR/full-graphdb-nifi
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-nifi:${TAG}

cd $DIR/full-graphdb-nifi-pt
docker build  --rm . -t pontusvisiongdpr/pontus-track-graphdb-nifi-pt:${TAG}

docker push pontusvisiongdpr/pontus-track-graphdb-odb:${TAG}
docker push pontusvisiongdpr/pontus-track-graphdb-odb-pt:${TAG}

docker push pontusvisiongdpr/pontus-track-graphdb-nifi-pt:${TAG}
docker push pontusvisiongdpr/pontus-track-graphdb-nifi:${TAG}
docker push pontusvisiongdpr/pontus-track-graphdb-base:${TAG}

#cd $DIR/full-graphdb-gui
#docker build --rm . -t pontusvisiongdpr/pontus-track-graphdb-gui
#docker push pontusvisiongdpr/pontus-track-graphdb-gui


