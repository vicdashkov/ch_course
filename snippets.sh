#!/usr/bin/env bash
docker exec -it some-clickhouse-server /bin/bash
docker exec -it src_ch_1 /bin/bash
docker-compose run --rm client --host ch
docker run -it --rm yandex/clickhouse-client --host localhost:9009
