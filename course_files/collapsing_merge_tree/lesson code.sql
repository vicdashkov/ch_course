-- tab 1

create database collapsing_merge_tree;

CREATE TABLE collapsing_merge_tree.pokemon_age
(
    pokemon_id UInt64,
    age UInt8,
    health String,
    sign Int8 DEFAULT 1
)
ENGINE = CollapsingMergeTree(sign)
ORDER BY pokemon_id

-- tab 2
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (1, 1, 'good', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (1, 1, 'good', -1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (1, 2, 'mhe', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (1, 5, 'mhe', -1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (1, 6, 'mhe mhe', 1);

-- tab 3
SELECT
    pokemon_id,
    sum(age * sign) AS age,
    anyLast(health) as health
FROM collapsing_merge_tree.pokemon_age
GROUP BY pokemon_id
HAVING sum(sign) > 0

SELECT * FROM collapsing_merge_tree.pokemon_age FINAL

-- tab 4
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (10, 1, 'awesome', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (10, 2, 'still awesome', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (10, 3, 'getting old', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (10, 4, 'awesome again', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (10, 5, 'now rally super old', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (10, 6, 'ready', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (10, 7, 'I want to live', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (10, 8, 'I want to live so much', 1);
INSERT INTO collapsing_merge_tree.pokemon_age VALUES (10, 9, 'yep, ready', 1);

select * from collapsing_merge_tree.pokemon_age

SELECT * FROM collapsing_merge_tree.pokemon_age FINAL
-- you'll see correct results,