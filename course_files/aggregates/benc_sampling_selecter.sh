#!/usr/bin/env bash

export QUERY="SELECT sum(type), uniq(pokemon_id) FROM aggregating.event"
python selecter.py

export QUERY="SELECT sumMerge(types_sum), uniqMerge(unique_id) FROM aggregating.event_aggs"
python selecter.py