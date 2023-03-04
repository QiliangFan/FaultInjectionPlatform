if [ ! -f apm-server.tar ] ; then
    minikube image save docker.elastic.co/apm/apm-server:8.4.2 apm-server.tar
fi