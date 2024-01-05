FROM ubuntu:20.04
LABEL maintainer="Alireza Gharib <alirezagharib110@gmail.com>"

WORKDIR /root
RUN apt install wget iptables iptables-persistent tzdata ca-certificates
RUN wget https://github.com/radkesvat/RTCF/releases/download/V$VERSION/RTCF_$ARCH_AMD-$VERSION.zip
RUN unzip RTCF_$ARCH_AMD-$VERSION.zip
RUN chmod +x ./RTCF

ENV ARCH=ST
ENV VERSION=0.6
ENV TZ=Asia/Tehran
CMD [ "/root/RTCF", "--auto:on --iran", "--lport:443 --password:123" ]
