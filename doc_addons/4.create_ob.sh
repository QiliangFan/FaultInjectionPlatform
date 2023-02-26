# OnlineBoutique
if [ ! -d helm-chart ] ; then
    cd ..
fi

# config OpenTelemetry to get the trace: https://www.elastic.co/guide/en/apm/guide/current/open-telemetry-direct.html#connect-open-telemetry-collector
# Meanwhile, must enable the OpenTelemetry in values.yaml of OnlineBoutique
# 1. Config the TLS  (must disable TLS of otlp), modify the TLS settings in `opentelemetry-collector.yaml``
# https://opentelemetry.io/docs/collector/configuration/
# 2. get a Secret key from kibana: https://www.elastic.co/guide/en/apm/guide/current/secret-token.html
SECRET=elastic
sed -i "s|endpoint: \".\+\"|endpoint: \"http://$(kubectl get service apm-server-apm-server -n elastic -o jsonpath={.spec.clusterIP}):8200\"|g" helm-chart/templates/opentelemetry-collector.yaml
sed -i "s/Authorization: .\+/Authorization: \"Bearer ${SECRET}\"/g" helm-chart/templates/opentelemetry-collector.yaml

# bash doc_addons/4.create_ob.sh
helm install onlineboutique ./helm-chart

cd doc_addons