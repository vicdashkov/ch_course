-- so, i created first table non sampling with less than ideal primary key, at least for sample by
SELECT
    count(),
    sum(type),
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0)
FROM sampling.bench_pokemon_event_non_sampling
┌───count()─┬─sum(type)─┬─uniq(type)─┬─sumIf(type, equals(modulo(pokemon_id, 2), 0))─┐
│ 365000000 │ 547496094 │          4 │                                     298629487 │
└───────────┴───────────┴────────────┴───────────────────────────────────────────────┘
1 rows in set. Elapsed: 26.314 sec. Processed 365.00 million rows, 1.46 GB (13.87 million rows/s., 55.48 MB/s.)
memory_usage: 9.80 MiB

-- and sample by table and clause. results are horrific. look at the processed storage. at memory 2x
SELECT
    count() * 10,
    sum(type) * 10,
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0) * 10
FROM sampling.bench_pokemon_event_sampling
SAMPLE 1 / 10
┌─multiply(count(), 10)─┬─multiply(sum(type), 10)─┬─uniq(type)─┬─multiply(sumIf(type, equals(modulo(pokemon_id, 2), 0)), 10)─┐
│             365071420 │               547642970 │          4 │                                                   298717390 │
└───────────────────────┴─────────────────────────┴────────────┴─────────────────────────────────────────────────────────────┘
1 rows in set. Elapsed: 65.129 sec. Processed 365.00 million rows, 4.38 GB (5.60 million rows/s., 67.25 MB/s.)
memory_usage: 19.32 MiB

-- is the whole table broken? looks like not. and yeah time elapses is better know. I blame docker
SELECT
    count(),
    sum(type),
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0)
FROM sampling.bench_pokemon_event_sampling
┌───count()─┬─sum(type)─┬─uniq(type)─┬─sumIf(type, equals(modulo(pokemon_id, 2), 0))─┐
│ 365000000 │ 547471949 │          4 │                                     298614001 │
└───────────┴───────────┴────────────┴───────────────────────────────────────────────┘
1 rows in set. Elapsed: 2.950 sec. Processed 365.00 million rows, 1.46 GB (123.74 million rows/s., 494.95 MB/s.)
memory_usage: 10.43 MiB

-- I'm like, maybe this is not the best query for sampling. lets try something else
select count() from sampling.bench_pokemon_event_non_sampling group by toYYYYMMDD(time)
365 rows in set. Elapsed: 2.065 sec. Processed 365.00 million rows, 1.46 GB (176.75 million rows/s., 706.98 MB/s.)
memory_usage: 6.23 MiB

-- almost 3x memory usage!
select count() * 10 from sampling.bench_pokemon_event_sampling sample 0.1 group by toYYYYMMDD(time)
365 rows in set. Elapsed: 2.356 sec. Processed 365.00 million rows, 4.38 GB (154.90 million rows/s., 1.86 GB/s.)
memory_usage: 15.95 MiB

-- but yeah the table itself seems to be OK
select count() * 10 from sampling.bench_pokemon_event_sampling group by toYYYYMMDD(time)
365 rows in set. Elapsed: 0.832 sec. Processed 365.00 million rows, 1.46 GB (438.90 million rows/s., 1.76 GB/s.)
memory_usage: 6.84 MiB

-- then I was like. look at this crappy primary key. It's not sparse enough for sampling! even left victorious in line comments
CREATE TABLE sampling.bench_pokemon_event_sampling_fix
(
  id UInt64,
  time DateTime,
  date Date,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time) -- could've used date; oh well, lost opportunity
ORDER BY (date, intHash32(id)) -- Sampling expression must be present in the primary key
SAMPLE BY intHash32(id);

-- created same sort of table without sample
CREATE TABLE sampling.bench_pokemon_event_non_sampling_fix
(
  id UInt64,
  time DateTime,
  date Date,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY date;

-- time sucks, but pretty much same stuff as we saw above
SELECT
    count(),
    sum(type),
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0)
FROM sampling.bench_pokemon_event_non_sampling_fix
1 rows in set. Elapsed: 27.106 sec. Processed 365.00 million rows, 1.46 GB (13.47 million rows/s., 53.86 MB/s.)
memory_usage: 11.21 MiB

-- okay better with new fancy primary key, but I think timing above was off due to who knows. memory still sucks
SELECT
    count() * 10,
    sum(type) * 10,
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0) * 10
FROM sampling.bench_pokemon_event_sampling_fix
SAMPLE 1 / 10
1 rows in set. Elapsed: 24.545 sec. Processed 40.30 million rows, 483.62 MB (1.64 million rows/s., 19.70 MB/s.)
memory_usage: 20.90 MiB

-- just as I though. no sample -> faster:(
SELECT
    count(),
    sum(type),
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0)
FROM sampling.bench_pokemon_event_sampling_fix
┌───count()─┬─sum(type)─┬─uniq(type)─┬─sumIf(type, equals(modulo(pokemon_id, 2), 0))─┐
│ 365000000 │ 547492357 │          4 │                                     298587031 │
└───────────┴───────────┴────────────┴───────────────────────────────────────────────┘
1 rows in set. Elapsed: 12.048 sec. Processed 365.00 million rows, 1.46 GB (30.30 million rows/s., 121.18 MB/s.)
memory_usage: 11.31 MiB

-- stupid slow docker
select count() from sampling.bench_pokemon_event_non_sampling_fix group by toYYYYMMDD(time)
365 rows in set. Elapsed: 19.593 sec. Processed 365.00 million rows, 1.46 GB (18.63 million rows/s., 74.52 MB/s.)
memory_usage: 6.73 MiB

-- aha, still 3x memory
select count() * 10 from sampling.bench_pokemon_event_sampling_fix sample 0.1 group by toYYYYMMDD(time)
365 rows in set. Elapsed: 9.243 sec. Processed 40.30 million rows, 483.62 MB (4.36 million rows/s., 52.32 MB/s.)
memory_usage: 16.12 MiB

-- rethinking the concept of PK for sampling; final attemp
CREATE TABLE sampling.bench_pokemon_event_sampling_fix_fix
(
  id UInt64,
  time DateTime,
  date Date,
  type UInt16,
  pokemon_id UInt16
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(time)
ORDER BY (date, intHash32(pokemon_id))
SAMPLE BY intHash32(pokemon_id);

-- accuracy sucks, and with such a sparse pk sample 0.5 is as good as you could do
SELECT
    count() * 2,
    sum(type) * 2,
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0) * 2
FROM sampling.bench_pokemon_event_sampling_fix_fix
SAMPLE 0.5
┌─multiply(count(), 2)─┬─multiply(sum(type), 2)─┬─uniq(type)─┬─multiply(sumIf(type, equals(modulo(pokemon_id, 2), 0)), 2)─┐
│            398170868 │              597239818 │          4 │                                                  298590148 │
└──────────────────────┴────────────────────────┴────────────┴────────────────────────────────────────────────────────────┘
1 rows in set. Elapsed: 1.410 sec. Processed 202.24 million rows, 808.97 MB (143.42 million rows/s., 573.68 MB/s.)
memory_usage: 12.06 MiB

-- yep. returns 0s :(
SELECT
    count() * 10,
    sum(type) * 10,
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0) * 10
FROM sampling.bench_pokemon_event_sampling_fix_fix
SAMPLE 0.1
┌─multiply(count(), 4)─┬─multiply(sum(type), 4)─┬─uniq(type)─┬─multiply(sumIf(type, equals(modulo(pokemon_id, 2), 0)), 4)─┐
│                    0 │                      0 │          0 │                                                          0 │
└──────────────────────┴────────────────────────┴────────────┴────────────────────────────────────────────────────────────┘

-- table still not broken
SELECT
    count(),
    sum(type),
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0)
FROM sampling.bench_pokemon_event_sampling_fix_fix
┌───count()─┬─sum(type)─┬─uniq(type)─┬─sumIf(type, equals(modulo(pokemon_id, 2), 0))─┐
│ 365000000 │ 547497907 │          4 │                                     298614314 │
└───────────┴───────────┴────────────┴───────────────────────────────────────────────┘
1 rows in set. Elapsed: 2.247 sec. Processed 365.00 million rows, 1.46 GB (162.40 million rows/s., 649.62 MB/s.)
memory_usage: 9.76 MiB

-- table size didn't reveal any surprises too.
SELECT table, formatReadableSize(size) as size, rows FROM (
    SELECT
        table,
        sum(bytes) AS size,
        sum(rows) AS rows,
        min(min_date) AS min_date,
        max(max_date) AS max_date
    FROM system.parts
    WHERE active
    GROUP BY table
    ORDER BY rows DESC
)
┌─table────────────────────────────────┬─size─────┬──────rows─┐
│ bench_pokemon_event_sampling         │ 3.67 GiB │ 365000000 │
│ bench_pokemon_event_sampling_fix     │ 4.66 GiB │ 365000000 │
│ bench_pokemon_event_non_sampling_fix │ 4.66 GiB │ 365000000 │
│ bench_pokemon_event_non_sampling     │ 3.67 GiB │ 365000000 │
│ bench_pokemon_event_sampling_fix_fix │ 4.18 GiB │ 365000000 │
└──────────────────────────────────────┴──────────┴───────────┘

-- that's it folks :(