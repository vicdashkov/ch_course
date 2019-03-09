-- TODO: remove this is temp

SELECT
    count(),
    sum(type),
    uniq(type),
    sumIf(type, (pokemon_id % 2) = 0)
FROM aggregating.event

┌───count()─┬─sum(type)─┬─uniq(type)─┬─sumIf(type, equals(modulo(pokemon_id, 2), 0))─┐
│ 365000000 │ 547461083 │          4 │                                     298624265 │
└───────────┴───────────┴────────────┴───────────────────────────────────────────────┘
1 rows in set. Elapsed: 2.961 sec. Processed 365.00 million rows, 1.46 GB (123.27 million rows/s., 493.07 MB/s.)

SELECT
    countMerge(count_events),
    sumMerge(types_sum),
    uniqMerge(unique_type),
    sumIfMerge(why_would_i_need_this)
FROM aggregating.event_aggs
┌─countMerge(count_events)─┬─sumMerge(types_sum)─┬─uniqMerge(unique_type)─┬─sumIfMerge(why_would_i_need_this)─┐
│                365000000 │           547461083 │                      4 │                         298624265 │
└──────────────────────────┴─────────────────────┴────────────────────────┴───────────────────────────────────┘

1 rows in set. Elapsed: 0.014 sec. Processed 96.36 thousand rows, 19.99 MB (6.81 million rows/s., 1.41 GB/s.)

SELECT count()
FROM aggregating.event_aggs

┌─count()─┐
│   96360 │
└─────────┘


 2019-03-09 08:38:15
SELECT count(), sum(type), uniq(type), sumIf(type, pokemon_id % 2 = 0) FROM aggregating.event
 attempt 0 took: 2.88978s
 attempt 1 took: 2.79921s
 attempt 2 took: 2.82621s

 2019-03-09 08:38:23
SELECT countMerge(count_events), sumMerge(types_sum), uniqMerge(unique_type), sumIfMerge(why_would_i_need_this) FROM aggregating.event_aggs
 attempt 0 took: 0.01936s
 attempt 1 took: 0.01007s
 attempt 2 took: 0.00825s

SELECT query, formatReadableSize(memory_usage)
FROM system.query_log WHERE type = 2 AND event_date = today()

query:                            SELECT countMerge(count_events), sumMerge(types_sum), uniqMerge(unique_type), sumIfMerge(why_would_i_need_this) FROM aggregating.event_aggs
formatReadableSize(memory_usage): 26.47 MiB

query:                            SELECT count(), sum(type), uniq(type), sumIf(type, pokemon_id % 2 = 0) FROM aggregating.event
formatReadableSize(memory_usage): 9.01 MiB

