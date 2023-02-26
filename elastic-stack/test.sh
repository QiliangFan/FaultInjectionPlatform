if [ ! -f apm-server.tar ] ; then
    minikube image save docker.elastic.co/apm/apm-server:8.5.1 apm-server.tar
fi