# 1. 环境准备

```bash
# docker-engine
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --output=yaml

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --output=yaml

# skaffold For Linux x86_64 (amd64)
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/
skaffold version

# minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version

# helm chart
sudo snap install helm --classic
```

# 2. 指令

> ```bash
>#  Watch the status of the frontend IP address with:
>    kubectl get --namespace default svc -w frontend-external
>
> # Get the external IP address of the frontend:
>    export SERVICE_IP=$(kubectl get svc --namespace default frontend-external --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
>    echo http://$SERVICE_IP
> ```


## 2.1 使用skaffold方式部署
```bash
#  部署 (这里推荐在~/.docker/config.json配置docker容器内部的代理)
skaffold run 

# 清理
skaffold delete
```

## 2.2 使用helm chart方式部署（推荐）

```bash
helm install onlineboutique ./helm-chart
```

## 2.3 暴露端口

```bash
# 暴露前端端口
kubectl expose service frontend --type=nodePort --target-port=80 --name=frontend-expose
# 加上--url参数就不会阻塞终端且会打印暴露的IP和端口
minikube service frontend-expose --url 
```

```bash
# 通过这种方式暴露端口可以直接从另一台机器上用局域网IP访问
kubectl port-forward service/frontend --address 0.0.0.0 8080:80 
```

## 2.4 配置Grafana和Prometheus

> 安装时如果设置了代理，务必设置no_proxy: `localhost,127.0.0.1,10.96.0.0/12,192.168.0.1/16,192.168.49.2`

```bash
sudo snap install helm --classic
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np

# 这一行打印账号“admin”的密码，需要记住！
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# 开放Grafana的端口，可供外部访问, 并自动打开浏览器访问
minikube service grafana-np

# 开放prometheus的端口，可供外部访问, 并自动打开浏览器访问
minikube service prometheus-server-np
```