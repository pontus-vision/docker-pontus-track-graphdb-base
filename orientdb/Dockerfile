############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################

FROM openjdk:8-jdk-alpine as BUILDER

MAINTAINER OrientDB LTD (info@orientdb.com)
 
# Override the orientdb download location with e.g.:
#   docker build -t mine --build-arg ORIENTDB_DOWNLOAD_SERVER=https://repo1.maven.org/maven2/com/orientechnologies/ .
ARG ORIENTDB_DOWNLOAD_SERVER

ENV ORIENTDB_VERSION 3.1.0-beta1
ENV ORIENTDB_DOWNLOAD_MD5 59bf93992576089cbfca66ba2abfc088
ENV ORIENTDB_DOWNLOAD_SHA1 3b3ea0a0a45df96896fb0cd974b729ee6e7d34bd

ENV ORIENTDB_DOWNLOAD_URL ${ORIENTDB_DOWNLOAD_SERVER:-https://central.maven.org/maven2/com/orientechnologies/orientdb-tp3/$ORIENTDB_VERSION/orientdb-tp3-$ORIENTDB_VERSION.tar.gz}
ENV ORIENTDB_DOWNLOAD_URL ${ORIENTDB_DOWNLOAD_SERVER:-https://repo1.maven.org/maven2/com/orientechnologies/orientdb-tp3/$ORIENTDB_VERSION/orientdb-tp3-$ORIENTDB_VERSION.tar.gz}

RUN apk add --update tar curl bash \
    && rm -rf /var/cache/apk/*

#download distribution tar, untar and DON'T delete databases (tp3 endopoint won't works if db isn't present)
RUN mkdir /orientdb && \
  wget  --no-check-certificate $ORIENTDB_DOWNLOAD_URL \
  && echo "$ORIENTDB_DOWNLOAD_MD5 *orientdb-tp3-$ORIENTDB_VERSION.tar.gz" | md5sum -c - \
  && echo "$ORIENTDB_DOWNLOAD_SHA1 *orientdb-tp3-$ORIENTDB_VERSION.tar.gz" | sha1sum -c - \
  && tar -xvzf orientdb-tp3-$ORIENTDB_VERSION.tar.gz -C /orientdb --strip-components=1 \
  && rm orientdb-tp3-$ORIENTDB_VERSION.tar.gz \
  && rm -rf /orientdb/databases/*

FROM openjdk:8-jdk-alpine


RUN apk add --update tar curl bash && \
    rm -rf /var/cache/apk/* && \
    addgroup -S -g 1000 orientdb && \
    adduser -S -u 1000 -g orientdb orientdb && \
    mkdir /orientdb /orientdb/bin /orientdb/lib /orientdb/log /orientdb/databases && \
    chown -R 1000:1000 /orientdb

USER 1000

COPY --chown=1000:1000   --from=BUILDER /orientdb/config/*     /orientdb/config/
COPY --chown=1000:1000   --from=BUILDER /orientdb/www/*     /orientdb/www/
COPY --chown=1000:1000   --from=BUILDER /orientdb/bin/*     /orientdb/bin/
COPY --chown=1000:1000   --from=BUILDER /orientdb/plugins/*     /orientdb/plugins/

#overrides internal gremlin-server to set binding to 0.0.0.0 instead of localhost
COPY --chown=1000:1000 --from=pontusvisiongdpr/pontus-jpostal-lib /pontus-jpostal-datadir /opt/pontus-graphdb/graphdb-current/datadir

COPY --chown=1000:1000 server.sh /orientdb/bin
RUN chmod 755 /orientdb/bin/server.sh

COPY --chown=1000:1000  demodb.properties gremlin-server.yaml security.json /orientdb/config/

COPY --chown=1000:1000 --from=pontusvisiongdpr/pontus-graphdb-odb-lib /root/.m2/repository/pv-gdpr/pontus-odb-graph/2.0.0/pontus-odb-graph-2.0.0.jar /orientdb/lib/
COPY --chown=1000:1000 --from=pontusvisiongdpr/pontus-graphdb-odb-conf /pontus-odb-graph/conf /orientdb/conf

RUN ln -s /tmp/libpostal.so /tmp/libpostal.so.1 || true && \
    ln -s /tmp/libjpostal_parser.so  /tmp/libjpostal_parser.so.1 || true

ENV PATH /orientdb/bin:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/tmp

VOLUME ["/orientdb/backup", "/orientdb/databases"]

WORKDIR /orientdb

#OrientDb binary
EXPOSE 2424

#OrientDb http
EXPOSE 2480

#Gremlin server
EXPOSE 8182

# Default command start the server
CMD ["server.sh"]
