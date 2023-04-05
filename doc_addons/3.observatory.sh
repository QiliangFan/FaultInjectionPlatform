#!/bin/bash

# pull images (If download image during deploying, it chances that the progress will frequently fail)
# cache the images for a quicker retry
cd ../

if [ ! -f apm-server.tar ] ; then
    minikube image load docker.elastic.co/apm/apm-server:8.4.2
    minikube image save docker.elastic.co/apm/apm-server:8.4.2 apm-server.tar
else
    minikube image load apm-server.tar
fi

if [ ! -f elasticsearch.tar ] ; then
    minikube image load docker.elastic.co/elasticsearch/elasticsearch:8.4.2
    minikube image save docker.elastic.co/elasticsearch/elasticsearch:8.4.2 elasticsearch.tar
else
    minikube image load elasticsearch.tar
fi

if [ ! -f filebeat.tar ] ; then
    minikube image load docker.elastic.co/beats/filebeat:8.4.2
    minikube image save docker.elastic.co/beats/filebeat:8.4.2 filebeat.tar
else
    minikube image load filebeat.tar
fi

if [ ! -f kibana.tar ] ; then
    minikube image load docker.elastic.co/kibana/kibana:8.4.2
    minikube image save docker.elastic.co/kibana/kibana:8.4.2 kibana.tar
else
    minikube image load kibana.tar
fi

if [ ! -f logstash.tar ] ; then
    minikube image load docker.elastic.co/logstash/logstash:8.4.2
    minikube image save docker.elastic.co/logstash/logstash:8.4.2 logstash.tar
else
    minikube image load logstash.tar
fi

if [ ! -f metricbeat.tar ] ; then
    minikube image load docker.elastic.co/beats/metricbeat:8.4.2
    minikube image save docker.elastic.co/beats/metricbeat:8.4.2 metricbeat.tar
else
    minikube image load metricbeat.tar
fi


# Chaos-mesh (for fault injection)
helm install chaos-mesh chaos-mesh/chaos-mesh -n=observe --version 2.5.1
helm upgrade chaos-mesh chaos-mesh/chaos-mesh --namespace=observe --version 2.5.1 --set dashboard.securityMode=false

# Elasticsearch (注意，必须要开启mnikube的这两个插件，否则无法成功运行elasticsearch)
minikube addons enable default-storageclass
minikube addons enable storage-provisioner
# ！下面这步是必须的：(因为ES的安装默认是分布式而非单机集群，因此需要修改)
cd elasticsearch/examples/minikube
sed -i 's/helm-es-minikube/elasticsearch/g' Makefile
sed -i "s/helm upgrade .\+ --wait/helm upgrade -n observe --wait/g" Makefile
sed -i 's/-Xmx128m -Xms128m/-Xmx512m -Xms512m/g' values.yaml
sed -i 's/memory: \"512M\"/memory: \"1024M\"/g' values.yaml
make install
# get the users's password
kubectl get secrets --namespace=observe elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
# get the username (default: elastic)
kubectl get secrets --namespace=observe elasticsearch-master-credentials -o jsonpath="{.data.username}" | base64 -d
cd -

# Elastic APM server
# An cert issue in v8.4.2+ (https://github.com/elastic/apm-server/issues/10332)
# 进入apm-server, 执行 `apm-server test output` 可以校验是否成功
helm install apm-server ./apm-server -n observe

# Kibana (请务必等elasticsearch运行成功再进行后续操作)
# 可以先再另一个namespace创建kibana把镜像下载好，然后再在elastic namespace中安装
helm install kibana ./kibana -n observe

# 如果要使用logstash需要filebeat
helm install filebeat ./filebeat -n observe

# Logstash
sed -i 's/helm-logstash-elasticsearch/logstash/g' logstash/examples/elasticsearch/Makefile
sed -i 's/upgrade --wait/upgrade -n observe --wait/g' logstash/examples/elasticsearch/Makefile
cd logstash/examples/elasticsearch
make install
cd -

# Metricbeat
# cd metricbeat
# helm dependency build
# cd ..
helm install metricbeat ./metricbeat -n observe

# # prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus -n observe

# # jaeger (请勿将jager的release name设置为`jaeger`，否则Grafana等其他工具可能会出错)
# helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
# cd jaeger
# helm dependency build
# cd ..
# helm install jaeger-tracing ./jaeger -n istio-system

# # grafana
# helm repo add grafana https://grafana.github.io/helm-charts
# helm install grafana grafana/grafana -n observe
# # Get passwd: 
# # kubectl get secret --namespace observe grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

cd ..
