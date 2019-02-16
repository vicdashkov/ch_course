-- creat merge tree old syntax
CREATE TABLE test
(
    id UInt16,
    date Date
)
ENGINE = MergeTree(date, (id, date), 8192);

SHOW PROCESSLIST

SELECT *
FROM system.functions
WHERE lower(name) LIKE ‘%sort%'
