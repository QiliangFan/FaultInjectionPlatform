import os

import matplotlib.pyplot as plt
import pandas as pd
from datetime import datetime
import matplotlib.dates as mdates


def plot(metric_file: str, out_file: str, figsize = (20, 10), day_interval=1, hour_interval=4):
    out_dir = os.path.dirname(out_file)
    if not os.path.exists(out_dir):
        os.makedirs(out_dir, exist_ok=True)

    dt = pd.read_csv(metric_file)
    ts = dt["ts"]
    values = dt["value"]
    date_list = list(map(lambda x: datetime.fromtimestamp(x), ts))

    fig, ax = plt.subplots(figsize=figsize)

    ax.xaxis.set_major_formatter(mdates.DateFormatter("%m-%d-%H"))
    ax.xaxis.set_major_locator(mdates.DayLocator(interval=day_interval))
    ax.xaxis.set_minor_locator(mdates.HourLocator(interval=hour_interval))

    ax.plot(date_list, values)

    plt.savefig(out_file, bbox_inches="tight")
    plt.close()


if __name__ == "__main__":
    plot("../output/adservice/container_blkio_device_usage_total.csv", "./test.png")