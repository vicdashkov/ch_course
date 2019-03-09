#!/usr/bin/env bash

export QUERY="SELECT count(), sum(type), uniq(type), sumIf(type, pokemon_id % 2 = 0) FROM aggregating.event"
python selecter.py

export QUERY="SELECT countMerge(count_events), sumMerge(types_sum), uniqMerge(unique_type), sumIfMerge(why_would_i_need_this) FROM aggregating.event_aggs"
python selecter.py