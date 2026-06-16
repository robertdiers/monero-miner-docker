FROM docker.io/ubuntu:24.04

RUN apt update && apt install -y curl bash cron python3 python3-psycopg2 python3-psutil software-properties-common kmod msr-tools linux-headers-$(uname -r)

RUN useradd -m robert
RUN echo "robert:123" | chpasswd
RUN mkdir -p /home/robert

COPY crontab.txt /etc/cron.d/container_cron
COPY xmrig_monitor.py /home/robert/xmrig_monitor.py

# give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/container_cron

# apply cron job
RUN crontab /etc/cron.d/container_cron

ENV WALLET_ADDRESS=""
ENV MAX_THREADS_HINT=100

COPY randomx_boost.sh randomx_boost.sh
COPY entrypoint.sh entrypoint.sh
ENTRYPOINT [ "bash", "entrypoint.sh" ]
