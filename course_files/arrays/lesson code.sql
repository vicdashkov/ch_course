-- tab 1

CREATE DATABASE arrays

CREATE TABLE arrays.pokemon_event
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_ids Array(UInt16)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (time, id);

INSERT INTO arrays.pokemon_event values(1, '2018-01-01 00:00:00', 1, [2222, 222, 777, 51228]);
INSERT INTO arrays.pokemon_event values(2, '2018-01-01 00:00:00', 1, [2222, 222]);
INSERT INTO arrays.pokemon_event values(3, '2018-01-01 00:00:00', 1, [2222]);
INSERT INTO arrays.pokemon_event values(3, '2018-01-01 00:00:00', 1, [8888]);

SELECT *
FROM arrays.pokemon_event

-- tab 2
SELECT
    id,
    arrayMap(pokemon_id -> dictGetString('pokemon_dict', 'name', toUInt64(pokemon_id)), pokemon_ids) AS names
FROM arrays.pokemon_event

-- tab 3
SELECT
    id event_id,
    dictGetString('pokemon_dict', 'name', toUInt64(arrayJoin(pokemon_ids))) name,
    arrayJoin(pokemon_ids) `pokemon id`
from arrays.pokemon_event

-- tab 4
SELECT
    id event_id,
    dictGetString('pokemon_dict', 'name', toUInt64(pokemon_id)) name,
    pokemon_id `pokemon id`
from arrays.pokemon_event
ARRAY JOIN pokemon_ids AS pokemon_id

SELECT
    id AS event_id,
    dictGetString('pokemon_dict', 'name', toUInt64(pokemon_id)) AS name,
    pokemon_id AS `pokemon id`,
    enum
FROM arrays.pokemon_event
ARRAY JOIN
    pokemon_ids AS pokemon_id,
    arrayEnumerate(pokemon_ids) AS enum
