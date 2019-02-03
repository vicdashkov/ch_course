import datetime
import random
import sys

TABLE_NAME = "event"
BULK_SIZE = 1000
EVENTS_PER_DAY = 1000
WORKERS = 5
DB_NAME = "aggregating"


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
        "type": event_type,
        "pokemon_id": pokemon_id
    }
