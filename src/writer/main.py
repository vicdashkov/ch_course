import asyncio
import logging

import asyncpool
from aioch import Client
import sys
import datetime
import random
import time
import argparse

from src.writer.utils import format_date_from_timestamp

parser = argparse.ArgumentParser()
parser.add_argument('--table_name', help="table name; default is ''", type=str, default="")
parser.add_argument('--bulk_size', help="# event to inset at once; default is 10000", type=int, default=10000)
parser.add_argument('--per_day', help="# event to inset per day; default is 1000000", type=int, default=1000000)
parser.add_argument('--workers', help="# of workers; default is 10", type=int, default=10)
args = parser.parse_args()

TABLE_NAME = args.table_name
BULK_SIZE = args.bulk_size
EVENTS_PER_DAY = args.per_day
WORKERS = args.workers

total_inserted_events = 0
pool = {}


def create_pool():
    for i in range(WORKERS):
        client = Client('localhost')
        pool[i] = {"c": client, "a": True}


def get_connection():
    for i, val in pool.items():
        if val['a']:
            val['a'] = False
            return i, val['c']


async def write_to_event(data: list, _):
    print(f"writing to {TABLE_NAME} {len(data)} rows")
    conn_id, conn = get_connection()
    await conn.execute(f'INSERT INTO pokemon.{TABLE_NAME} VALUES', data)

    global total_inserted_events
    total_inserted_events += len(data)

    return_connection(conn_id)


def return_connection(connection_id):
    pool[connection_id]['a'] = True


def generate_random_event(event_date: datetime.datetime) -> dict:
    event_id = random.randint(0, sys.maxsize)
    event_type = random.randint(0, 3)
    pokemon_id = random.randint(0, 10)
    event_date = event_date.replace(
        hour=random.randint(0, 23),
        minute=random.randint(0, 59))

    return {
        "id": event_id,
        "time": event_date,
        # "date": event_date.date(),
        "type": event_type,
        "pokemon_id": pokemon_id}


def generate_random_events(event_date: datetime.datetime, number_events: int) -> list:
    return [generate_random_event(event_date) for _ in range(number_events)]


async def fill_events(_loop, number_per_day, bulk_size):
    async with asyncpool.AsyncPool(
            _loop,
            num_workers=WORKERS,
            worker_co=write_to_event,
            max_task_time=300,
            log_every_n=10,
            name="CHPool",
            logger=logging.getLogger("CHPool")) as p:

        insert_time = datetime.datetime(2018, 1, 1)
        for i in range(356):  # TODO: FIX
            for _ in range(int(number_per_day / bulk_size)):
                events = generate_random_events(insert_time, bulk_size)
                await p.push(events, None)

            insert_time = insert_time + datetime.timedelta(days=1)


def log_experiment(experiment_took):
    with open("experiments_log.txt", 'a') as f:
        text = f"{format_date_from_timestamp(time.time())} - " \
               f"table: {TABLE_NAME} - " \
               f"inserted: {total_inserted_events} - " \
               f"took: {round(experiment_took, 2)} - " \
               f"bulk size: {BULK_SIZE} - " \
               f"events per day: {EVENTS_PER_DAY} - " \
               f"workers: {WORKERS}\n"
        f.write(text)


if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    create_pool()

    start = time.time()
    print("inserter started at", format_date_from_timestamp(start))
    loop.run_until_complete(fill_events(loop, EVENTS_PER_DAY, BULK_SIZE))
    end = time.time()
    took = end - start
    print(f"inserter ended at {format_date_from_timestamp(end)}; took: {took} seconds")
    log_experiment(took)
