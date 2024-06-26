#! /bin/bash
cd /var/lib/jenkins/workspace/hotstar-app/
sudo su - jenkins -s/bin/bash
#docker logout   master.dns.com
sudo  docker login -u admin --password Harbor12345 master.dns.com
 sudo docker image build -t  $JOB_NAME:v1.$BUILD_ID .
sudo docker image tag $JOB_NAME:v1.$BUILD_ID master.dns.com/hotstar/$JOB_NAME:v1.$BUILD_ID
sudo docker image tag $JOB_NAME:v1.$BUILD_ID master.dns.com/hotstar/$JOB_NAME:latest
sudo docker image push master.dns.com/hotstar/$JOB_NAME:v1.$BUILD_ID
sudo docker  push master.dns.com/hotstar/$JOB_NAME:latest
sudo docker image rmi $JOB_NAME:v1.$BUILD_ID  master.dns.com/hotstar/$JOB_NAME:v1.$BUILD_ID   master.dns.com/hotstar/$JOB_NAME:latest
