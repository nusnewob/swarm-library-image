FROM alpine:3.4
RUN apk update && apk add curl

COPY ./swarm /usr/local/bin/swarm
COPY ./certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

ENV SWARM_HOST :2375
EXPOSE 2375

VOLUME /.swarm

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["help"]
