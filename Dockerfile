FROM centos as builder

RUN  yum -y update && \
     yum install -y java  && \
     yum -y install attr bind-utils docbook-style-xsl gcc gdb krb5-workstation \
                    libsemanage-python libxslt perl perl-ExtUtils-MakeMaker \
                    perl-Parse-Yapp perl-Test-Base pkgconfig policycoreutils-python  \
                    python-crypto gnutls-devel libattr-devel keyutils-libs-devel \
                    libacl-devel libaio-devel libblkid-devel libxml2-devel openldap-devel \
                    pam-devel popt-devel python-devel readline-devel zlib-devel systemd-devel \
                    autoconf make &&\
     yum clean all && \
     rm -rf /var/cache/yum

RUN mkdir /pontus-jpostal
RUN yum install -y git automake libtool && \
    yum clean all && \
    rm -rf /var/cache/yum

ENV JAVA_HOME=/etc/alternatives/jre
RUN git clone --single-branch --branch master https://github.com/pontusvision/libpostal.git
RUN mkdir /pontus-jpostal-datadir && \
    cd libpostal && \
    ./bootstrap.sh && \
    ./configure --datadir=/pontus-jpostal-datadir && \
    make -j4

RUN cd libpostal && \
    make install


RUN git clone --single-branch --branch master https://github.com/pontusvision/pontus-jpostal.git
RUN cd pontus-jpostal && \
    yum install -y java-1.8.0-openjdk-devel file && \
    export JAVA_HOME=/etc/alternatives/java_sdk_1.8.0 && \
    sed -i 's/PKG_CHECK_MODULES/#PKG_CHECK_MODULES/g' configure.ac && \
    sed -i 's#/c/work/pontus-git/pontusvision-x/tech#/#g ; s#win-amd64#linux-x86_64#g' src/main/c/Makefile.am && \
    ./bootstrap.sh && \
    ./configure --libdir=$(pwd)/src/main/resources/lib/linux-x86_64   --disable-static --enable-shared && \
    ./gradlew install

RUN yum -y install maven

RUN git clone --depth 1 --single-branch --branch master https://github.com/pontusvision/pontus-natty.git
RUN cd pontus-natty && \
    mvn clean install package -DskipTests

RUN git clone  --depth 1 --single-branch --branch master https://github.com/pontusvision/pontus-gdpr-graph.git
RUN cd pontus-gdpr-graph && \
    mvn clean package install -DskipTests

RUN cd /root/.m2/repository && for i in *; do if [[ "com" == $i || "pv-gdpr" == $i ]]; then echo skip ; else rm -r $i; fi; done    

FROM alpine as final
RUN apk upgrade -q --no-cache
RUN apk add -q --no-cache \
      bash \
      gettext \
      git \
      maven \
      openjdk8 \
      openjdk8-jre-base \
      openssl \
      unzip \
      zip 

COPY --from=builder /root/.m2/ /root/.m2/
