FROM prom/prometheus:latest

COPY prometheus.yml /etc/prometheus/prometheus.yml

WORKDIR /etc/prometheus

EXPOSE 9090

CMD ["--config.file=/etc/prometheus/prometheus.yml"]