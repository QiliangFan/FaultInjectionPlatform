import os
from glob import glob

from client import Client
from yaml import full_load
import pandas as pd
from tqdm import tqdm
import time

from plot import plot

START_TS = 1676556000
# END_TS = 1676598900
END_TS = int(time.time())


def get_metrics():
    client = Client(config["api"])
    all_metrics = client.all_metrics()
    for metric_name in tqdm(all_metrics, total=len(all_metrics)):
        for pod in config["pods"]:
            data = client.query_range(f"{metric_name}", pod, START_TS, END_TS)["values"]
            out_dir = os.path.join(output, f"{pod}")
            if not os.path.exists(out_dir):
                os.makedirs(out_dir)
            out_file = os.path.join(out_dir,  f"{metric_name}.csv")
            ts_list = []
            value_list = []
            for ts, value in data:
                value = float(value)
                ts_list.append(ts)
                value_list.append(value)
            dt = pd.DataFrame({
                "ts": ts_list,
                "value": value_list
            })
            dt.to_csv(out_file, index=False)


def plot_images():
    metrics = glob(os.path.join("output", "**", "*.csv"), recursive=True)
    outputs = [v.replace("output", "img_output").replace(".csv", ".png") for v in metrics]
    for metric, out_file in tqdm(zip(metrics, outputs), total=len(metrics)):
        plot(metric, out_file, hour_interval=1)



def main():
    # get metrics
    get_metrics()

    # plot the images
    plot_images()




if __name__ == "__main__":
    config = full_load(open("config.yaml", "r"))
    output = "output"

    main()