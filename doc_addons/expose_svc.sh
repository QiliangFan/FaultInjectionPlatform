# The kibana dashboard
kubectl port-forward svc/kibana-kibana -n elastic 5601:5601 --address 0.0.0.0

kubectl port-forward svc/elasticsearch-master 9200 -n elastic --address 0.0.0.0