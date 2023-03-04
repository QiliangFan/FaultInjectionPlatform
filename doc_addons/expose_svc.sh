# The elasticsearch
kubectl port-forward svc/elasticsearch-master 9200 -n observe --address 0.0.0.0

# The kibana
kubectl port-forward svc/kibana-kibana -n observe 5601:5601 --address 0.0.0.0

# The Jaeger
kubectl port-forward svc/jaeger-tracing-query -n observe 8081:80 --address 0.0.0.0

# The Grafana
kubectl port-forward svc/grafana -n observe 8080:80 --address 0.0.0.0
# kubectl get secret --namespace observe grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
