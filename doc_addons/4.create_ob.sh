# OnlineBoutique
if [ ! -d helm-chart ] ; then
    cd ..
fi

# remove old images
minikube image ls | grep fanqiliang | xargs -i sh -c "minikube image rm {}"

# bash doc_addons/4.create_ob.sh
helm install onlineboutique ./helm-chart

cd doc_addons