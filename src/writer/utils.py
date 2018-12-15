import datetime


def format_date_from_timestamp(posix_time):
    return datetime.datetime.utcfromtimestamp(posix_time).strftime('%Y-%m-%d T%H:%M:%S')
