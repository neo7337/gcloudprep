# /bin/sh

project="myProjectCreate2"
projectId="mytest-project-202"
bucketName="testBucket"
instanceGroupName="test-ig"
instaneTemplate="test-it"

#   create the gcp project with the below command
gcloud projects create $projectId --name=$project --set-as-default

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
gsutil mb gs://$bucketName

#   creating an instance template
gcloud beta compute --project=$projectId instance-templates create $instaneTemplate --machine-type=f1-micro --subnet=projects/cli-project-101/regions/us-west1/subnetworks/west1-subnet --network-tier=PREMIUM --metadata=^,@^lab-logs-bucket=gs://$bucketName,@startup-script=$dir --maintenance-policy=MIGRATE --service-account=738364898483-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.write_only --region=us-west1 --tags=open-ssh-tag --image=debian-9-stretch-v20191210 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$instaneTemplate --labels== --reservation-affinity=any

#   now create the gce instance-group using the instance template with the previous startup-script
gcloud beta compute --project=$projectId instance-groups managed create $instanceGroupName --base-instance-name=$instanceGroupName --template=$instaneTemplate --size=1 --zones=us-west2-a,us-west2-b,us-west2-c --instance-redistribution-type=PROACTIVE

gcloud beta compute --project $projectId instance-groups managed set-autoscaling $instanceGroupName --region "us-west2" --cool-down-period "30" --max-num-replicas "3" --min-num-replicas "2" --target-cpu-utilization "0.6" --mode "on"
