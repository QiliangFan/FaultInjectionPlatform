# 1. 生成token以访问Chaos-mesh dashboard


转发端口
```bash
kubectl port-forward -n chaos-mesh svc/chaos-dashboard --address 0.0.0.0 2333:2333
```

生成并获取访问密钥
```bash
kubectl apply -f rbac.yaml
kubectl create token account-cluster-manager-bjrvn
```