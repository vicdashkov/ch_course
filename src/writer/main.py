from clickhouse_driver import Client
import sys
import datetime
import random
import time
import argparse
from utils import format_date_from_timestamp

parser = argparse.ArgumentParser()
parser.add_argument(
    '--table_suffix', help="suffix for event table; default is ''", type=str, default="")
parser.add_argument(
    '--bulk_size', help="# event to inset at once; default is 10000", type=int, default=10000)
parser.add_argument(
    '--per_day', help="# event to inset per day; default is 1000000", type=int, default=1000000)
args = parser.parse_args()

# EVENT_TABLE_SUFFIX = getattr(args, "table_suffix", "")
EVENT_TABLE_SUFFIX = args.table_suffix
BULK_SIZE = args.bulk_size
EVENTS_PER_DAY = args.per_day

client = Client('localhost')


def write_to_event(data: list):
    client.execute(
        f'INSERT INTO pokemon.event{EVENT_TABLE_SUFFIX} VALUES', data)


def generate_random_event(event_date: datetime.date) -> dict:
    event_id = random.randint(0, sys.maxsize)
    event_type = random.randint(0, 1000)
    pokemon_id = random.randint(0, 10000)
    return {
        "id": event_id,
        "time": event_date,
        "type": event_type,
        "pokemon_id": pokemon_id}


def generate_random_events(event_date: datetime.date, number_events: int) -> list:
    return [generate_random_event(event_date) for _ in range(number_events)]


def fill_events(number_per_day: int, bulk_size: int):
    '''
        will put 1 month worth of events to even table
    '''
    day_month = 30
    insert_time = datetime.datetime(2018,11,1)
    for i in range(day_month):
        for _ in range(int(number_per_day / bulk_size)):
            events = generate_random_events(insert_time, bulk_size)
            write_to_event(events)

        insert_time = insert_time + datetime.timedelta(days=1)


if __name__ == '__main__':
    start = time.time()
    print("inserter started at", format_date_from_timestamp(start))

    fill_events(EVENTS_PER_DAY, BULK_SIZE)

    end = time.time()
    print(f"inserter ended at {format_date_from_timestamp(end)}; took: {end - start} seconds")
