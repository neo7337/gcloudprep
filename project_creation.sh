# /bin/sh

projectId="cli-project-102"

#   create the gcp project with the below command
gcloud projects create $projectId --name="myNewCliProject" --set-as-default

account_id=$(gcloud alpha billing accounts list --format="value(name)")

#   link the project to the billing account
gcloud alpha billing accounts projects link $projectId --account-id=$account_id

#   enable the compute engine api explicitly as it is not enabled by default
gcloud services enable compute.googleapis.com

#   clone the startup-script to a location from the following git repo and use the 
#   following script to setup the instance

#   get the path where the files are cloned and save the path to a variable
dir=$(pwd)/startup-script.sh
echo "$dir"

#   create the gcp storage bucket
gsutil mb gs://bucketcli2

#   now create the gce instance with the previous startup-script
gcloud compute instances create cliinstance101 --zone us-central1-a  --machine-type=f1-micro --scopes=default,gke-default,storage-rw --metadata-from-file startup-script=$dir --metadata=lab-logs-bucket=gs://bucketcli2
