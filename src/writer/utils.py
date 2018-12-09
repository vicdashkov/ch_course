import datetime

def format_date_from_timestamp(posix_time):
    datetime.datetime.utcfromtimestamp(posix_time).strftime('%Y-%m-%dT%H:%M:%SZ')