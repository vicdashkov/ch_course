CREATE TABLE merge_tree.event_time_batch
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (time, id);
-- pay attention to order of fields

CREATE TABLE merge_tree.event_time_single
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (time, id);

CREATE TABLE merge_tree.even_time_order_func_batch
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (toYYYYMM(time), id);

CREATE TABLE merge_tree.even_time_order_func_single
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (toYYYYMM(time), id);

CREATE TABLE merge_tree.event_date_batch
(
  id UInt64,
  time DateTime,
  date Date,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY date
ORDER BY (date, id);

CREATE TABLE merge_tree.event_date_single
(
  id UInt64,
  time DateTime,
  date Date,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY date
ORDER BY (date, id);