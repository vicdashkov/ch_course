-- tab 1

SELECT * FROM system.dictionaries

-- tab 2

CREATE DATABASE dicts

CREATE TABLE dicts.event
(
  id UInt64,
  time DateTime,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (time, id);

INSERT INTO dicts.event (id, type, pokemon_id)
values
(1, 2, 2222),
(2, 2, 222),
(3, 2, 777),
(4, 2, 51228),
(5, 2, 1111)

-- tab 3
SELECT
    id AS event_id,
    dictGetString('pokemon_dict', 'name', toUInt64(pokemon_id)) AS name,
    dictGetString('pokemon_dict', 'pet_name', toUInt64(pokemon_id)) AS pet_name
FROM pokemon.event_2_distributed

-- tab 4
system reload dictionaries

-- tab 5
CREATE TABLE dicts.pokemon_names
(
    id UInt64,
    name String,
    pet_name String
)
ENGINE = Dictionary(pokemon_dict)

SELECT
    id AS event_id,
    name,
    pet_name
FROM
(
    SELECT
        id,
        toUInt64(pokemon_id) AS pokemon_id
    FROM dicts.event
)
ANY LEFT JOIN
(
    SELECT
        id AS pokemon_id,
        name,
        pet_name
    FROM dicts.pokemon_names
) USING (pokemon_id);

SELECT * FROM dicts.pokemon_names