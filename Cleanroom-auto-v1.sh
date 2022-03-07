#!/bin/bash
## 1) prepare the envoirnment file 
. env
##2) Prepare the cluster ready
## cENM cluster creation ##

START_TIME=$SECONDS
gcloud beta container --project "$project-name" clusters create "$cluster-name" --region "$region-name" --no-enable-basic-auth --cluster-version "1.20.10-gke.1600" --release-channel "regular" --machine-type "$machine-type-1" --image-type "COS_CONTAINERD" --disk-type "pd-ssd" --disk-size "100" --node-labels node=ericingress --metadata disable-legacy-endpoints=true --node-taints node=routing:NoSchedule --scopes "https://www.googleapis.com/auth/cloud-platform" --max-pods-per-node "110" --num-nodes "1" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-private-nodes --master-ipv4-cidr "$master-ipv4-cidr" --enable-ip-alias --network "projects/$project-name/global/networks/vpc-network" --subnetwork "projects/$project-name/regions/$region-name/subnetworks/vpc-network" --cluster-ipv4-cidr "$cluster-ipv4-cidr" --services-ipv4-cidr "$services-ipv4-cidr" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "$region-name-a","$region-name-c" && gcloud beta container --project "$project-name" node-pools create "app-pool" --cluster "$cluster-name" --region "$region-name" --machine-type "$machine-type-2" --image-type "COS_CONTAINERD" --disk-type "pd-ssd" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/cloud-platform" --num-nodes "7" --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --max-pods-per-node "110" --node-locations "$region-name-a","$region-name-c" 
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo " GCP Cluster "$cluster-name" duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  


## Create file-store in GCP ##
START_TIME=$SECONDS
gcloud beta filestore instances create $filestore-name --project=$project-name --zone=$region-name-a --tier=BASIC_SSD --file-share=name="nfs_store",capacity=3000 --network=name="vpc-network" 
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "GCP file-Store "$filestore-name" duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  


##3) dowload unzip file the csar file

mkdir $home/$csar-dir
wget <csar.zip>  $home
unzip <csar.zip>  $home/$csar-dir/

##4) modify the files


##5) install the charts

## Connecing the GKE Cluster ###
echo "$cluster-name GKE cluster connecting..."
gcloud container clusters get-credentials $cluster-name --region $region-name --project $project-name
sleep 5
echo "$cluster-name GKE cluster Connected."

## install the NFS provisioner ##
START_TIME=$SECONDS
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \ 
    --set nfs.server=$(gcloud beta filestore instances list) \ 
    --set nfs.path=/nfs_share 
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "NFS provisioner install duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

## Create a namespace
echo "Creating namespace.. "
kubectl create ns $ns-name
echo " $ns-name created"


# Install the BRO Chart
START_TIME=$SECONDS
echo "installing bro chart.."
cd $chart_home
helm install eric-enm-bro-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-bro-integration-1.5.0-2.tgz --namespace $ns-name --wait --timeout 300s > ~/bro_integration-time.log 2>&1 
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "BRO Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

# Install the Monitoring Chart"
START_TIME=$SECONDS
echo "Installing Monitoring Chart..."
helm install eric-enm-monitoring-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-monitoring-integration-1.10.0-30.tgz --namespace $ns-name --wait --timeout 600s > ~/monitoring_integration.log 2>&1 
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Monitoring Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

## Install the Pre-Deploy Chart"

START_TIME=$SECONDS
echo "Installing Pre-Deploy Chart..."
nohup helm install eric-enm-pre-deploy-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-pre-deploy-integration-1.5.0-3.tgz --namespace $ns-name --wait --timeout 500s > ~/pre_deploy_integration.log 2>&1
sleep 5
LAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Pre-Deploy Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

## Install the Infra Chart"
START_TIME=$SECONDS
echo "Installing Infra Chart..."
helm install eric-enm-infra-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-infra-integration-1.10.0-34.tgz --namespace $ns-name --wait --timeout 18000s > ~/infra_integration.log 2>&1 
sleep 5
LAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Infra Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

## Install the Stateless Chart"
START_TIME=$SECONDS
echo "Installing Stateless Chart..."
helm install eric-enm-stateless-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-stateless-integration-1.10.0-28.tgz --namespace $ns-name --wait --timeout 14400s > ~/stateless_integration.log 2>&1 
sleep 5
LAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Stateless Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  


##6) validate the cluster
web_page=$(curl http://localhost)

for item in <Laptop Drone VR Watch Phone>
do
  check_item "$web_page" $item
done


