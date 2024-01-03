FROM ubuntu:20.04
LABEL maintainer="Alireza Gharib <alirezagharib110@gmail.com>"

WORKDIR /root
RUN apt install wget iptables iptables-persistent tzdata ca-certificates
RUN wget https://github.com/radkesvat/RTCF/releases/download/V0.3/RTCF_ST_AMD-0.3.zip
RUN unzip RTCF_ST_AMD-0.3.zip
RUN chmod +x ./RTCF

ENV TZ=Asia/Tehran
CMD [ "/root/RTCF", "--auto:on --iran", "--lport:443 --password:123" ]
