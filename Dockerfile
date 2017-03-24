

FROM ubuntu:14.04.3
MAINTAINER drc <caiwenzhe2021@gmail.com>
RUN apt-get update && \
    apt-get install -y python-pip libnet1 libnet1-dev libpcap0.8 libpcap0.8-dev git

RUN git clone https://github.com/dextercai/net-speeder.git net-speeder
WORKDIR net-speeder
RUN sh build.sh

RUN mv net_speeder /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/net_speeder

FROM alpine:3.4
ENV SSR_URL https://github.com/shadowsocksr/shadowsocksr/archive/manyuser.zip

RUN set -ex \
    && apk --update add --no-cache libsodium py-pip \
    && pip --no-cache-dir install $SSR_URL \
    && rm -rf /var/cache/apk

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8388
ENV PASSWORD    p@ssw0rd
ENV METHOD      aes-256-cfb
ENV PROTOCOL    auth_sha1_compatible
ENV OBFS        http_simple_compatible
ENV TIMEOUT     300

EXPOSE $SERVER_PORT/tcp
EXPOSE $SERVER_PORT/udp

WORKDIR /usr/bin/
CMD nohup /usr/local/bin/net_speeder venet0 "ip" >/dev/null 2>&1 &
CMD ssserver -s $SERVER_ADDR \
             -p $SERVER_PORT \
             -k $PASSWORD    \
             -m $METHOD      \
             -O $PROTOCOL    \
             -o $OBFS        \
             -t $TIMEOUT
