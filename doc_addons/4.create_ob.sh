# OnlineBoutique
if [ ! -d helm-chart ] ; then
    cd ..
fi

# config OpenTelemetry to get the trace: https://www.elastic.co/guide/en/apm/guide/current/open-telemetry-direct.html#connect-open-telemetry-collector
# Meanwhile, must enable the OpenTelemetry in values.yaml of OnlineBoutique
sed -i "s|endpoint: \".\+\"|endpoint: \"http://$(kubectl get service jaeger-collector -n observe -o jsonpath={.spec.clusterIP}):14250\"|g" helm-chart/templates/opentelemetry-collector.yaml

# bash doc_addons/4.create_ob.sh
helm install onlineboutique ./helm-chart

cd doc_addons