# Security

This example deploy Filebeat 8.5.1 using authentication and TLS to connect to
Elasticsearch (see [values][]).


## Usage

* Deploy [Elasticsearch Helm chart][].

* Deploy Filebeat chart with security: `make install`

* You can now setup a port forward to query Filebeat indices:

  ```
  kubectl port-forward svc/security-master 9200
  curl -u elastic:changeme https://localhost:9200/_cat/indices
  ```


## Testing

You can also run [goss integration tests][] using `make test`


[elasticsearch helm chart]: https://github.com/elastic/helm-charts/tree/main/elasticsearch/examples/security/
[goss integration tests]: https://github.com/elastic/helm-charts/tree/main/filebeat/examples/security/test/goss.yaml
[values]: https://github.com/elastic/helm-charts/tree/main/filebeat/examples/security/values.yaml
