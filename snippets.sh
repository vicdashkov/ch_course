#!/usr/bin/env bash
docker exec -it some-clickhouse-server /bin/bash
docker exec -it src_ch_1 /bin/bash
docker-compose run --rm client --host ch
docker-compose run --rm client --host ch -u vic --password 12345 --database=pokemon
docker run -it --rm yandex/clickhouse-client --host 0.0.0.0

apt-get update && \
apt-get install apt-file && \
apt-file update && \
apt-get install vim