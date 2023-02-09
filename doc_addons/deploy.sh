# 最好不要整个脚本一起执行, proxy_ip需要修改为自己的代理IP
export proxy_ip=10.11.57.211
export http_proxy=http://$proxy_ip:7890
export https_proxy=http://$proxy_ip:7890
export HTTP_PROXY=http://$proxy_ip:7890
export HTTPS_PROXY=http://$proxy_ip:7890
export no_proxy=localhost,127.0.0.1,10.96.0.0/12,192.168.0.1/16,192.168.49.2
export NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,192.168.0.1/16,192.168.49.2

if  [ ! -d ~/.docker ] ; then
    mkdir ~/.docker
fi

echo '{ 
 "proxies":
 {
   "default":
   {
     "httpProxy": "proxy",
     "httpsProxy": "proxy",
     "noProxy": "localhost,127.0.0.1,10.96.0.0/12,192.168.0.1/16,192.168.49.2"
   }
 }
}' | sed "s|proxy|$http_proxy|g" | tee ~/.docker/config.json

# minikube start --image-mirror-country=cn --registry-mirror https://dockerhub.azk8s.cn

minikube start --docker-env http_proxy $http_proxy --docker-env https_proxy $https_proxy --docker-env no_proxy $no_proxy --cpus=4 --memory 4096 --disk-size 32g


# OnlineBoutique
helm install onlineboutique ./helm-chart

# Promethues
sudo snap install helm --classic
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np

# Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode | tee chaos-mesh/Grafana_token.txt

# Jaeger
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm install jaeger jaegertracing/jaeger


# Chaos-mesh
helm repo add chaos-mesh https://charts.chaos-mesh.org
kubectl create ns chaos-mesh
helm install chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --version 2.5.1
cd chaos-mesh
kubectl apply -f rbac.yaml
kubectl create token account-cluster-manager-bjrvn > chaos_mesh_token.txt
cd ..