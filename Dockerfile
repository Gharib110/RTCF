FROM ubuntu:20.04
LABEL maintainer="Alireza Gharib <alirezagharib110@gmail.com>"

WORKDIR /root
RUN apt install wget iptables iptables-persistent
RUN wget https://github.com/radkesvat/ReverseTlsTunnel/releases/download/V7.1/v7.1_linux_amd64.zip
RUN unzip v7.1_linux_amd.zip
RUN chmod +x ./RTT

ENV TZ=Asia/Tehran
CMD [ "/root/RTT", "-config", "/etc/xray/config.json" ]
