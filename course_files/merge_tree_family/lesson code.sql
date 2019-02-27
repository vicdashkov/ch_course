CREATE DATABASE merge_tree;

CREATE TABLE merge_tree.event
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree();
-- this won’t work

SELECT table, formatReadableSize(size) as size, rows, days, formatReadableSize(avgDaySize) as avgDaySize FROM (
    SELECT
        table,
        sum(bytes) AS size,
        sum(rows) AS rows,
        min(min_date) AS min_date,
        max(max_date) AS max_date,
        (max_date - min_date) AS days,
        size / (max_date - min_date) AS avgDaySize
    FROM system.parts
    WHERE active
    GROUP BY table
    ORDER BY rows DESC
);


