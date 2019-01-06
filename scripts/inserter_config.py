import datetime
import random
import sys

TABLE_NAME = "pokemon_event_2"
BULK_SIZE = 10
EVENTS_PER_DAY = 10
WORKERS = 10
DB_NAME = "sampling"


def generate_random_event(event_date: datetime.datetime) -> dict:
    event_id = random.randint(0, sys.maxsize)
    event_type = random.randint(0, 3)
    pokemon_id = random.randint(0, 10)
    event_datetime = event_date.replace(
        hour=random.randint(0, 23),
        minute=random.randint(0, 59))

    return {
        "id": event_id,
        "time": event_datetime,
        # "date": event_date.date(),
        "type": event_type,
        "pokemon_id": pokemon_id,
        "location_id": pokemon_id}
