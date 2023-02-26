#!/bin/bash

# pull images (If download image during deploying, it chances that the progress will frequently fail)
# cache the images for a quicker retry
cd ../
if [ ! -f apm-server.tar ] ; then
    minikube image load docker.elastic.co/apm/apm-server:8.5.1
    minikube image save docker.elastic.co/apm/apm-server:8.5.1 apm-server.tar
else
    minikube image load apm-server.tar
fi

if [ ! -f elasticsearch.tar ] ; then
    minikube image load docker.elastic.co/elasticsearch/elasticsearch:8.5.1
    minikube image save docker.elastic.co/elasticsearch/elasticsearch:8.5.1 elasticsearch.tar
else
    minikube image load elasticsearch.tar
fi

if [ ! -f filebeat.tar ] ; then
    minikube image load docker.elastic.co/beats/filebeat:8.5.1
    minikube image save docker.elastic.co/beats/filebeat:8.5.1 filebeat.tar
else
    minikube image load filebeat.tar
fi

if [ ! -f kibana.tar ] ; then
    minikube image load docker.elastic.co/kibana/kibana:8.5.1
    minikube image save docker.elastic.co/kibana/kibana:8.5.1 kibana.tar
else
    minikube image load kibana.tar
fi

if [ ! -f logstash.tar ] ; then
    minikube image load docker.elastic.co/logstash/logstash:8.5.1
    minikube image save docker.elastic.co/logstash/logstash:8.5.1 logstash.tar
else
    minikube image load logstash.tar
fi

if [ ! -f metricbeat.tar ] ; then
    minikube image load docker.elastic.co/beats/metricbeat:8.5.1
    minikube image save docker.elastic.co/beats/metricbeat:8.5.1 metricbeat.tar
else
    minikube image load metricbeat.tar
fi

# Chaos-mesh (for fault injection)
# helm repo add chaos-mesh https://charts.chaos-mesh.org
# kubectl create ns chaos-mesh
# helm install chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --version 2.5.1
# cd chaos-mesh
# kubectl apply -f rbac.yaml
# kubectl create token account-cluster-manager-bjrvn > chaos_mesh_token.txt
# cd ..

kubectl create namespace elastic
cd elastic-stack

# Elasticsearch (注意，必须要开启mnikube的这两个插件，否则无法成功运行elasticsearch)
minikube addons enable default-storageclass
minikube addons enable storage-provisioner
# ！下面这步是必须的：(因为ES的安装默认是分布式而非单机集群，因此需要修改)
# modify the `createCert: false` to `createCert: true` to disable ssl 
# modify the `protocol: https` to `protocol: http`
cd elasticsearch/examples/minikube
sed -i 's/helm-es-minikube/elasticsearch/g' Makefile
sed -i 's/helm upgrade --wait/helm upgrade -n elastic --wait/g' Makefile
sed -i 's/-Xmx128m -Xms128m/-Xmx512m -Xms512m/g' values.yaml
sed -i 's/memory: \"512M\"/memory: \"1024M\"/g' values.yaml
make install
# get the users's password
kubectl get secrets --namespace=elastic elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
# get the username (default: elastic)
kubectl get secrets --namespace=elastic elasticsearch-master-credentials -o jsonpath="{.data.username}" | base64 -d
# 获取Pod所需镜像
kubectl get pod elasticsearch-master-0 -n elastic -o jsonpath="{.spec.containers[*].image}"
# minikube ssh docker image pull docker.elastic.co/elasticsearch/elasticsearch:8.5.1
cd -

# Elastic APM server
helm install apm-server ./apm-server -n elastic
# minikube ssh docker image pull docker.elastic.co/apm/apm-server:8.5.1

# Kibana (请务必等elasticsearch运行成功再进行后续操作)
# 可以先再另一个namespace创建kibana把镜像下载好，然后再在elastic namespace中安装
helm install kibana ./kibana -n elastic
# kubectl get pod pre-install-kibana-kibana-4cbnn -n elastic -o jsonpath="{.spec.containers[*].image}"
# minikube ssh docker image pull docker.elastic.co/kibana/kibana:8.5.1
# To uninstall Kibana, please do as follow first：
# > kubectl delete configmap kibana-kibana-helm-scripts -n elastic

# 如果要使用logstash需要filebeat
helm install filebeat ./filebeat -n elastic
# kubectl get pod filebeat-filebeat-8plcv -n elastic -o jsonpath="{.spec.containers[*].image}"

# Logstash
sed -i 's/helm-logstash-elasticsearch/logstash/g' logstash/examples/elasticsearch/Makefile
sed -i 's/upgrade --wait/upgrade -n elastic --wait/g' logstash/examples/elasticsearch/Makefile
cd logstash/examples/elasticsearch
make install
cd -
# helm install logstash ./logstash -n elastic
kubectl get pod logstash-logstash-0 -n elastic -o jsonpath="{.spec.containers[*].image}"
# minikube ssh docker image pull docker.elastic.co/logstash/logstash:8.5.1

# Metricbeat
cd ./metricbeat
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm dependency build
cd -
helm install metricbeat ./metricbeat -n elastic
# Get all the images:
# kubectl get deployments -n elastic -o wide

cd doc_addons