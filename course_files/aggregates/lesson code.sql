-- tab 1
CREATE DATABASE aggregating

CREATE TABLE aggregating.event
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (time, id);

CREATE MATERIALIZED VIEW aggregating.event_aggs
ENGINE = AggregatingMergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (time, id)
AS SELECT
    id,
    time,
    sumState(type)    AS types_sum,
    uniqState(pokemon_id) AS unique_id
FROM aggregating.event
GROUP BY id, time;

-- tab 2
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 1, 1);
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 2, 1);
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 2, 1);
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 3, 2);
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 4, 3);

-- tab 3
SELECT sum(type), uniq(pokemon_id) FROM aggregating.event

SELECT
    sumMerge(types_sum),
    uniqMerge(unique_id)
FROM aggregating.event_aggs