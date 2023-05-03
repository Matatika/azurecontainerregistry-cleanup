#!/bin/bash
# see https://medium.com/@anantvardhan.04/azure-container-registry-acr-cleanup-dfeb8a8bb6a9
REPOSITORY_DELIMITED=`echo $1 | tr "," "\n"`
REGISTRY=$2
RETENTION=$3
ENABLE_DELETE=$ENABLE_DELETE
if [ $ENABLE_DELETE = true ]
then
for REPO in $REPOSITORY_DELIMITED
do
echo "Performing cleanup for $REPO"
az acr repository show-tags --name $REGISTRY --repository $REPO \
--orderby time_asc -o tsv | head -n -$RETENTION | xargs -I% az acr repository delete --name $REGISTRY --image $REPO:% --yes

az acr repository show-manifests --name $REGISTRY --repository $REPO --query "[?tags[0]==null].digest" -o tsv | xargs -I% az acr repository delete --name $REGISTRY --image $REPO@% --yes

done
else
for REPO in $REPOSITORY_DELIMITED
do
echo "No data deleted."
echo "Set ENABLE_DELETE=true to enable deletion of below images in $REPO:"
az acr repository show-tags --name $REGISTRY --repository $REPO \
--orderby time_asc -o tsv | head -n -$RETENTION

az acr repository show-manifests --name $REGISTRY --repository $REPO --query "[?tags[0]==null].digest" -o tsv

done
fi
