#!/usr/bin/env bash

export TABLE_NAME=event
export BULK_SIZE=100000
export DB_NAME=sampling
export HAS_DATE_COLUMN=0
export EVENTS_PER_DAY=1000000
python inserter.py
