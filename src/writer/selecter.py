import argparse
import time
from clickhouse_driver import Client

from src.writer.utils import format_date_from_timestamp

parser = argparse.ArgumentParser()
parser.add_argument('--benchmark_runs', help="number of times to run select; default 3", type=int, default=3)
args = parser.parse_args()

NUMBER_BENCHMARK_RUNS = args.benchmark_runs

QUERY = ""

client = Client('localhost')


def select_with_timing() -> int:
    start = time.time()
    print(client.execute(QUERY))
    end = time.time()
    return end - start


def benchmark_query():
    with open("selecter_experiments_log.txt", 'a') as f:
        text = '\n '
        text += format_date_from_timestamp(time.time())
        text += '\n'
        text += QUERY
        for i in range(NUMBER_BENCHMARK_RUNS):
            text += f"\n attempt {i} took: {round(select_with_timing(), 5)}s"
        text += '\n'
        f.write(text)

if __name__ == '__main__':
    benchmark_query()
