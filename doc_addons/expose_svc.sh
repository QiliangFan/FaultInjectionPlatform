# The elasticsearch
kubectl port-forward svc/elasticsearch-master 9200 -n elastic --address 0.0.0.0

# The Jaeger