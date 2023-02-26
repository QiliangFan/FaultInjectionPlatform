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

# echo '{ 
#  "proxies":
#  {
#    "default":
#    {
#      "httpProxy": "proxy",
#      "httpsProxy": "proxy",
#      "noProxy": "localhost,127.0.0.1,10.96.0.0/12,192.168.0.1/16,192.168.49.2"
#    }
#  }
# }' | sed "s|proxy|$http_proxy|g" | tee ~/.docker/config.json

# minikube start --image-mirror-country=cn --registry-mirror https://dockerhub.azk8s.cn

minikube start --docker-env http_proxy $http_proxy --docker-env https_proxy $https_proxy --docker-env no_proxy $no_proxy --cpus=8 --memory 16384 --disk-size 128g
