# Overview

This repository automates the configuration of recurring etcd backups in OpenShift using GitOps.

# Attribution

This work was largely based on this blog post by Saurabh Kumar Ghoshal on redhat.com:

https://developers.redhat.com/articles/2024/09/26/enable-etcd-backups-openshift-clusters-hybrid-cloud-environments

From that blog post came the overall idea for how to run the recurring backups, the implementation related to creating the etcd backups themselves, the CronJob, and the s3 client.

This repository adds Helm / GitOps / a shell script to bootstrap everything. It also changes the s3 command to work with a third party S3 equivalent by using and endpoint URL instead of an S3 region.

# Prerequisites

1. ACM
2. OpenShift GitOps (ArgoCD)
3. An S3 bucket, which can be AWS, or IBM Cloud Object Storage or an equivalent

# Instructions

## High Level Instructions

This procedure has multiple high level steps:

1. Run the install script
2. Create the IBM Cloud Object Storage credentials in Vaultwarden
3. Create the Application in ACM

## Set the S3 Credentials

Ideally these would be configured in Vaultwarden and imported into OpenShift using the External Secrets Operator, but that has not been tested in the lab yet. So, the install script will create a Secret.

To do this manually:

1. Stop sharing your screen :)
2. Run these commands, filling in your details
```
export ENDPOINT_URL=<paste>
export AWS_ACCESS_KEY_ID=<paste>
export AWS_SECRET_ACCESS_KEY=<paste>
```

## Run the install script

```
./install.sh
```

This will:

* Create the namespace
* Check that the correct environment variables are set
* Configure the ServiceAccount permissions to run privileged Pods
* Create the Secret the old fashion way. You should configure Vaultwarden (or an equivalent) instead if you have time
* Creates the GitOps Application to cause OpenShift GitOps to run the Helm chart and actually create the objects in OpenShift

