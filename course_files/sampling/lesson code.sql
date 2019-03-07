-- tab 1

CREATE DATABASE sampling

CREATE TABLE sampling.event
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (time, id);

insert into sampling.event (id, time)
values
(1, now()),
(2, now()),
(3, now());

SELECT *
FROM sampling.event

SELECT *
FROM sampling.event
SAMPLE 1/10


-- tab 2
CREATE TABLE sampling.pokemon_event -- pokemon here signifies that we got it right this time
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
SAMPLE BY intHash32(id)
PARTITION BY toYYYYMM(time)
ORDER BY (time, intHash32(id));

insert into sampling.pokemon_event(id)
values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

SELECT count()
FROM sampling.pokemon_event
SAMPLE 0.5

-- tab 3
CREATE TABLE sampling.bench_pokemon_event_sampling
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
SAMPLE BY intHash32(id)
PARTITION BY toYYYYMM(time)
ORDER BY (time, intHash32(id));

CREATE TABLE sampling.bench_pokemon_event_non_sampling
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (time, intHash32(id));

-- tab 4
SELECT query, formatReadableSize(memory_usage)
FROM system.query_log WHERE type = 2 AND event_date = today()