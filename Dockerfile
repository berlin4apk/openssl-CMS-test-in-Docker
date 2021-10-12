# syntax=docker/dockerfile:1.3-labs
#ARG TAG=3.14
#ARG TAG=edge
#ARG TAG=3.14
#FROM alpine:$TAG

ARG BASE_IMAGE=alpine:3.14
FROM ${BASE_IMAGE}

ARG VERSION SHA256

RUN \
#RUN --mount=type=cache,id=apk,target=/var/cache/apk ln -vs /var/cache/apk /etc/apk/cache && \
  apk update && \
  apk upgrade && \
  apk add \
    alpine-sdk \
    curl \
    linux-headers \
    perl \
    zlib-dev \
    zstd-dev zstd ccache ccache-doc sudo

####  && rm -rf /var/cache/apk/* ||:

RUN cd /usr/local/bin && ln -s /usr/lib/ccache/bin/* . && mkdir -p "/ccache" && mkdir -p "/dev/shm/ccache/"  && mkdir -p "/tmp/ccache/" ;

#RUN cat <<EOF > /etc/ccache.conf
COPY <<EOF /etc/ccache.conf
#cache_dir=/ccache/
#cache_dir=/dev/shm/ccache/
cache_dir=/tmp/ccache/
compression=false
#compression_level
#file_clone=true
hard_link=false
umask=002
secondary_storage="http://172.17.0.1:8080|layout=bazel"
max_size=500M
# reshare (CCACHE_RESHARE or CCACHE_NORESHARE, see Boolean values above)
# If true, ccache will write results to secondary storage even for primary storage cache hits. The default is false.
reshare=true
EOF


RUN mkdir -p /usr/local/src/ && cd /usr/local/src/ && \
  ###curl https://www.openssl.org/source/openssl-${VERSION}.tar.gz -o openssl-${VERSION}.tar.gz && \
  ###sha256sum openssl-${VERSION}.tar.gz | grep ${SHA256} && \
  ###tar -xf openssl-${VERSION}.tar.gz && \
  ###cd /usr/local/src/openssl-${VERSION} && \
  git clone -n https://github.com/openssl/openssl.git openssl-git 
  #&& \
  RUN cd /usr/local/src/ && cd openssl-git && git checkout c3b5fa4ab7d19e35311a21fec3ebc0a333c352b6
  ADD https://patch-diff.githubusercontent.com/raw/openssl/openssl/pull/15348.patch /usr/local/src/openssl-CMS-sign-digest-PR15348.patch
  RUN cd /usr/local/src/ && cd openssl-git && ls -latr /usr/local/src/ && git apply --check /usr/local/src/*.patch && git apply /usr/local/src/*.patch
RUN adduser -D -g '' user
#ENV CC "ccache gcc"
#ENV CXX "ccache g++"
#RUN export CC="ccache gcc"; export CXX="ccache g++"; mkdir -p "$HOME/.ccache"; \

#RUN --mount=type=cache,id=ccache,target=/tmp/ccache CCACHE_DIR=/tmp/ccache ccache -s
RUN CCACHE_DIR=/tmp/ccache ccache -s

RUN cd /usr/local/src/openssl-git \
#RUN --mount=type=cache,id=ccache,target=/tmp/ccache CCACHE_DIR=/tmp/ccache cd /usr/local/src/openssl-git \
  && ccache -s \
  && ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib \
  && make #\
RUN CCACHE_DIR=/tmp/ccache cd /usr/local/src/openssl-git \
#RUN --mount=type=cache,id=ccache,target=/tmp/ccache CCACHE_DIR=/tmp/ccache cd /usr/local/src/openssl-git \
  && make TESTS=-test_afalg test #\
RUN CCACHE_DIR=/tmp/ccache cd /usr/local/src/openssl-git \
#RUN --mount=type=cache,id=ccache,target=/tmp/ccache CCACHE_DIR=/tmp/ccache cd /usr/local/src/openssl-git \
  && make install #\
  && ccache -s \
  # && apk del alpine-sdk curl linux-headers perl zlib-dev ccache \
  && adduser -D -g '' openssl \
  && echo "/usr/local/ssl/lib:/lib:/usr/local/lib:/usr/lib" > /etc/ld-musl-$(arch).path #\
  ### && rm /usr/local/src/openssl-${VERSION}.tar.gz \
  ### && rm -rf /usr/local/src/openssl-${VERSION}


#RUN


###USER openssl
USER user

WORKDIR /

ENV \
  PATH=/usr/local/ssl/bin:$PATH \
  SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
  SSL_CERT_DIR=/etc/ssl/certs

###ENTRYPOINT [ "openssl" ]
