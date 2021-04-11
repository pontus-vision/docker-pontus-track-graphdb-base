############################################################
# Dockerfile to run an OrientDB (Graph) Container
############################################################

FROM openjdk:8-jdk-slim-buster as BUILDER

MAINTAINER OrientDB LTD (info@orientdb.com)
 
# Override the orientdb download location with e.g.:
#   docker build -t mine --build-arg ORIENTDB_DOWNLOAD_SERVER=https://repo1.maven.org/maven2/com/orientechnologies/ .
ARG ORIENTDB_DOWNLOAD_SERVER

ENV ORIENTDB_VERSION 3.1.0
ENV ORIENTDB_DOWNLOAD_MD5 7c233ea871147154ac1e5b265711a9a3
ENV ORIENTDB_DOWNLOAD_SHA1 f609f711c2b1ce5d702006a408e4210a9644e7f8

ENV ORIENTDB_DOWNLOAD_URL ${ORIENTDB_DOWNLOAD_SERVER:-https://central.maven.org/maven2/com/orientechnologies/orientdb-tp3/$ORIENTDB_VERSION/orientdb-tp3-$ORIENTDB_VERSION.tar.gz}
ENV ORIENTDB_DOWNLOAD_URL ${ORIENTDB_DOWNLOAD_SERVER:-https://repo1.maven.org/maven2/com/orientechnologies/orientdb-tp3/$ORIENTDB_VERSION/orientdb-tp3-$ORIENTDB_VERSION.tar.gz}

RUN apt update -y && \
    apt install -y tar curl bash wget && \
    apt autoremove -y

#download distribution tar, untar and DON'T delete databases (tp3 endopoint won't works if db isn't present)
RUN mkdir /orientdb && \
  wget  --no-check-certificate $ORIENTDB_DOWNLOAD_URL \
  && echo "$ORIENTDB_DOWNLOAD_MD5 *orientdb-tp3-$ORIENTDB_VERSION.tar.gz" | md5sum -c - \
  && echo "$ORIENTDB_DOWNLOAD_SHA1 *orientdb-tp3-$ORIENTDB_VERSION.tar.gz" | sha1sum -c - \
  && tar -xvzf orientdb-tp3-$ORIENTDB_VERSION.tar.gz -C /orientdb --strip-components=1 \
  && rm orientdb-tp3-$ORIENTDB_VERSION.tar.gz \
  && rm -rf /orientdb/databases/*

FROM openjdk:8-jdk-slim-buster


RUN apt update -y && \
    apt install -y tar curl bash s3fs && \
    apt autoremove -y && \
    groupadd --system -g 1000 orientdb && \
    sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf && \
    useradd -u 1000 -g orientdb orientdb -d /orientdb && \
    mkdir /orientdb /orientdb/bin /orientdb/lib /orientdb/log /orientdb/databases && \
    echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY | sed -e 's/ //g' > /orientdb/.passwd-s3fs && \
    chmod 400 /orientdb/.passwd-s3fs && \
    chown -R 1000:1000 /orientdb

USER 1000

COPY --chown=1000:1000   --from=BUILDER /orientdb/www/*     /orientdb/www/
COPY --chown=1000:1000   --from=BUILDER /orientdb/bin/*     /orientdb/bin/
COPY --chown=1000:1000   --from=BUILDER /orientdb/config/*     /orientdb/config/
COPY --chown=1000:1000   --from=BUILDER /orientdb/plugins/*     /orientdb/plugins/

#overrides internal gremlin-server to set binding to 0.0.0.0 instead of localhost
COPY --chown=1000:1000 --from=pontusvisiongdpr/pontus-jpostal-lib:1.13.2 /pontus-jpostal-datadir /opt/pontus-graphdb/graphdb-current/datadir

COPY --chown=1000:1000 server.sh /orientdb/bin
RUN chmod 755 /orientdb/bin/server.sh

COPY --chown=1000:1000  demodb.properties gremlin-server.yaml security.json /orientdb/config/

COPY --chown=1000:1000 --from=pontusvisiongdpr/pontus-graphdb-odb-lib:1.13.2 /root/.m2/repository/pv-gdpr/pontus-odb-graph/2.0.0/pontus-odb-graph-2.0.0.jar /orientdb/lib/

COPY --chown=1000:1000 --from=pontusvisiongdpr/pontus-graphdb-odb-conf:1.13.2 /pontus-odb-graph/conf /orientdb/conf

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

ENV S3_BUCKET=orientdb-test
ENV MOUNT_POINT=/orientdb/databases
ENV REGION=eu-west-2
#ENV IAM_ROLE=orientdb-role
ENV IAM_ROLE=auto
ENV S3_ACL=private

USER root
CMD /usr/bin/s3fs ${S3_BUCKET} ${MOUNT_POINT} -o uid=1000,gid=1000,use_cache=/tmp,url=https://s3.amazonaws.com,endpoint=${REGION},iam_role=${IAM_ROLE},allow_other,nosuid,nonempty,nodev,default_acl=${S3_ACL},retries=5 -d

USER 1000
# Default command start the server
CMD ["server.sh"]

