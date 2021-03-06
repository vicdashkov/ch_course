#!/usr/bin/env bash

export TABLE_NAME=bench_pokemon_event_sampling
export BULK_SIZE=100000
export DB_NAME=sampling
export HAS_DATE_COLUMN=0
export EVENTS_PER_DAY=1000000
python inserter.py

export TABLE_NAME=bench_pokemon_event_non_sampling
export BULK_SIZE=100000
export DB_NAME=sampling
export HAS_DATE_COLUMN=0
export EVENTS_PER_DAY=1000000
python inserter.py

export TABLE_NAME=bench_pokemon_event_sampling_fix
export BULK_SIZE=100000
export DB_NAME=sampling
export HAS_DATE_COLUMN=1
export EVENTS_PER_DAY=1000000
python inserter.py

export TABLE_NAME=bench_pokemon_event_non_sampling_fix
export BULK_SIZE=100000
export DB_NAME=sampling
export HAS_DATE_COLUMN=1
export EVENTS_PER_DAY=1000000
python inserter.py

export TABLE_NAME=bench_pokemon_event_sampling_fix_fix
export BULK_SIZE=100000
export DB_NAME=sampling
export HAS_DATE_COLUMN=1
export EVENTS_PER_DAY=1000000
python inserter.py