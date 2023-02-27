#!/bin/bash

# pull images (If download image during deploying, it chances that the progress will frequently fail)
# cache the images for a quicker retry
cd ../

if [ ! -f elasticsearch.tar ] ; then
    minikube image load docker.elastic.co/elasticsearch/elasticsearch:8.5.1
    minikube image save docker.elastic.co/elasticsearch/elasticsearch:8.5.1 elasticsearch.tar
else
    minikube image load elasticsearch.tar
fi

if [ ! -f logstash.tar ] ; then
    minikube image load docker.elastic.co/logstash/logstash:8.5.1
    minikube image save docker.elastic.co/logstash/logstash:8.5.1 logstash.tar
else
    minikube image load logstash.tar
fi


# Chaos-mesh (for fault injection)
# helm repo add chaos-mesh https://charts.chaos-mesh.org
# kubectl create ns chaos-mesh
# helm install chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --version 2.5.1
# cd chaos-mesh
# kubectl apply -f rbac.yaml
# kubectl create token account-cluster-manager-bjrvn > chaos_mesh_token.txt
# cd ..

kubectl create namespace observe
cd observe

# Elasticsearch (注意，必须要开启mnikube的这两个插件，否则无法成功运行elasticsearch)
minikube addons enable default-storageclass
minikube addons enable storage-provisioner
# ！下面这步是必须的：(因为ES的安装默认是分布式而非单机集群，因此需要修改)
# modify the `createCert: false` to `createCert: true` to disable ssl 
# modify the `protocol: https` to `protocol: http`
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
# 获取Pod所需镜像
kubectl get pod elasticsearch-master-0 -n observe -o jsonpath="{.spec.containers[*].image}"
# minikube ssh docker image pull docker.elastic.co/elasticsearch/elasticsearch:8.5.1
cd -

# Logstash
sed -i 's/helm-logstash-elasticsearch/logstash/g' logstash/examples/elasticsearch/Makefile
sed -i 's/upgrade --wait/upgrade -n observe --wait/g' logstash/examples/elasticsearch/Makefile
cd logstash/examples/elasticsearch
make install
cd -
# helm install logstash ./logstash -n observe
kubectl get pod logstash-logstash-0 -n observe -o jsonpath="{.spec.containers[*].image}"
# minikube ssh docker image pull docker.elastic.co/logstash/logstash:8.5.1

# prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus -n observe

# grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana -n observe

# jaeger
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm install jaeger jaegertracing/jaeger -n observe
4
cd doc_addons