-- tabix tab 1
CREATE DATABASE merge_tree;

CREATE TABLE merge_tree.event
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree(); -- this won’t work

-- tab 2 in
CREATE TABLE merge_tree.event_time
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

CREATE TABLE merge_tree.event_time_order_func
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (toYYYYMM(time), id);

CREATE TABLE merge_tree.event_date
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
