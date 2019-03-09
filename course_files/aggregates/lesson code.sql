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
PARTITION BY toYYYYMM(hour)
ORDER BY (hour, pokemon_id)
AS SELECT
    pokemon_id,
    toStartOfHour(time) hour,
    sumState(type) AS types_sum,
    uniqState(type) AS unique_type,
    sumIfState(type, pokemon_id % 2 = 0) as why_would_i_need_this
FROM aggregating.event
GROUP BY toStartOfHour(time), pokemon_id;

-- tab 2
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 1, 1);
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 2, 1);
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 2, 1);
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 3, 2);
INSERT INTO aggregating.event values(2, '2018-01-02 00:00:00', 4, 3);

-- tab 3
SELECT sum(type), uniq(type), sumIf(type, pokemon_id % 2 = 0) FROM aggregating.event

SELECT
    sumMerge(types_sum),
    uniqMerge(unique_type),
    sumIfMerge(why_would_i_need_this)
FROM aggregating.event_aggs