from prometheus_api_client import PrometheusConnect
from datetime import datetime
from typing import Union

invalid_metrics = [
    "container_scrape_error",
    "container_ulimits_soft",
    "container_network_receive_packets_dropped_total",
    "container_fs_io_time_seconds_total",
    "container_fs_io_time_weighted_seconds_total",
    "container_fs_limit_bytes",
    "container_fs_read_seconds_total",
    "container_fs_reads_merged_total",
    "container_blkio_device_usage_total"
]

class Client:

    def __init__(self, url: str):
        self.prom = PrometheusConnect(url, disable_ssl=True)

    def query_range(self, metric_name: str, pod: str, start_time: Union[int, datetime], end_time: Union[int, datetime], step: int = 300):
        if isinstance(start_time, int):
            start_time = datetime.fromtimestamp(start_time)
        if isinstance(end_time, int):
            end_time = datetime.fromtimestamp(end_time)

        if metric_name.endswith("_total") or metric_name in ['container_last_seen', 'container_memory_cache', 'container_memory_max_usage_bytes']:
            data = self.prom.custom_query_range(f"rate({metric_name}{{pod=~'{pod}.+'}}[5m])", start_time, end_time, step=step)
        else:
            data = self.prom.custom_query_range(f"{metric_name}{{pod=~'{pod}.+'}}", start_time, end_time, step=step)
        if len(data) == 0:
            print(metric_name, pod)
        return data[0]

    def all_metrics(self):
        all_metrics = self.prom.all_metrics()
        all_metrics = list(filter(lambda x: True if x.startswith("container") and not x.startswith("container_fs") and not x.startswith("container_network") and x not in invalid_metrics else False, all_metrics))
        return all_metrics