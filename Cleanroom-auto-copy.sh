#!/bin/bash
## 1) prepare the envoirnment file 
echo "Reading the envoirnment Details.."
export project_name="causal-binder-334615"
export cluster_name="cenm-cluster"
export region_name="europe-north1"
export machine_type_1="e2-standard-2"
#machine-type-2=e2-highmem-16"
export master_ipv4_cidr="172.30.16.64/28"
export cluster_ipv4_cidr="10.1.64.0/18"
export services_ipv4_cidr="10.32.64.0/20"
#filestore-name=cenm-filestore
#csar-dir=<CNM_CSAR_NAME>
export ns_name="enm01"
export home=$(pwd)
network_name=default

##2) Prepare the cluster ready
## cENM cluster creation ##

echo " $cluster_name cluster is creating in $region_name...."
echo ""
START_TIME=$SECONDS
gcloud beta container --project "$project_name" clusters create "$cluster_name" --region "$region_name" --no-enable-basic-auth --cluster-version "1.20.12-gke.1500" --release-channel "regular" --machine-type "$machine_type_1" --image-type "COS_CONTAINERD" --disk-type "pd-ssd" --disk-size "100" --node-labels node=ericingress --metadata disable-legacy-endpoints=true --node-taints node=routing:NoSchedule --scopes "https://www.googleapis.com/auth/cloud-platform" --max-pods-per-node "110" --num-nodes "1" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-private-nodes --master-ipv4-cidr $master_ipv4_cidr --enable-ip-alias --network "projects/$project_name/global/networks/$network_name" --subnetwork "projects/$project_name/regions/$region_name/subnetworks/$network_name" --cluster-ipv4-cidr $cluster_ipv4_cidr --services-ipv4-cidr $services_ipv4_cidr --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,NodeLocalDNS,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "$region_name-a","$region_name-c"
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo " GCP Cluster "$cluster_name" duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  
echo ""

## Create file-store in GCP ##
echo "$GCP file-Store $filestore_name creating..."
echo ""
START_TIME=$SECONDS
#gcloud beta filestore instances create $filestore-name --project=$project-name --zone=$region-name-a --tier=BASIC_SSD --file-share=name="nfs_store",capacity=3000 --network=name="vpc-network" 
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "GCP file-Store $filestore_name duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  
echo ""


##3) dowload unzip file the csar file

#mkdir $home/$csar-dir
#wget <csar.zip>  $home
#unzip <csar.zip>  $home/$csar-dir/

##uploading images to GCR.



##4) modify the Intigration Yaml




##5) install the charts

## Connecing the GKE Cluster ###
echo "$cluster_name GKE cluster connecting..."
gcloud container clusters get-credentials $cluster_name --region $region_name --project $project_name
sleep 5
echo "$cluster_name GKE cluster Connected."

## install the NFS provisioner ##
START_TIME=$SECONDS
#helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \ 
#    --set nfs.server=$(gcloud beta filestore instances list) \ 
#    --set nfs.path=/nfs_share 
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "NFS provisioner install duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

## Create a namespace
echo "Creating namespace.. "
kubectl create ns $ns_name
echo " $ns_name created"


# Install the BRO Chart
START_TIME=$SECONDS
echo "installing bro chart.."
#cd $chart_home
#helm install eric-enm-bro-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-bro-integration-1.5.0-2.tgz --namespace $ns-name --wait --timeout 300s > ~/bro_integration-time.log 2>&1 
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "BRO Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

# Install the Monitoring Chart"
START_TIME=$SECONDS
echo "Installing Monitoring Chart..."
#helm install eric-enm-monitoring-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-monitoring-integration-1.10.0-30.tgz --namespace $ns-name --wait --timeout 600s > ~/monitoring_integration.log 2>&1 
sleep 5
ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Monitoring Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

## Install the Pre-Deploy Chart"

START_TIME=$SECONDS
echo "Installing Pre-Deploy Chart..."
#helm install eric-enm-pre-deploy-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-pre-deploy-integration-1.5.0-3.tgz --namespace $ns-name --wait --timeout 500s > ~/pre_deploy_integration.log 2>&1
sleep 5
LAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Pre-Deploy Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

## Install the Infra Chart"
START_TIME=$SECONDS
echo "Installing Infra Chart..."
#helm install eric-enm-infra-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-infra-integration-1.10.0-34.tgz --namespace $ns-name --wait --timeout 18000s > ~/infra_integration.log 2>&1 
sleep 5
LAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Infra Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

## Install the Stateless Chart"
START_TIME=$SECONDS
echo "Installing Stateless Chart..."
#helm install eric-enm-stateless-integration-enm01 --values $home/$csar-dir/Scripts/eric-enm-integration-production-values-1.6.0-13.yaml eric-enm-stateless-integration-1.10.0-28.tgz --namespace $ns-name --wait --timeout 14400s > ~/stateless_integration.log 2>&1 
sleep 5
LAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Stateless Chart installation completed and duration :" "$(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  


##6) validate the cluster
#web_page=$(curl http://localhost)

#for item in <Laptop Drone VR Watch Phone>
#do
#  check_item "$web_page" $item
#done


