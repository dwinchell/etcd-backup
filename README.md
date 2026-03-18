# Overview

This automates the configuration of recurring etcd backups in OpenShift.

# Attribution

This work was largely based on this blog post by Saurabh Kumar Ghoshal on redhat.com:

https://developers.redhat.com/articles/2024/09/26/enable-etcd-backups-openshift-clusters-hybrid-cloud-environments

From that blog post came the overall idea for how to run the recurring backups, the implementation related to creating the etcd backups themselves, the CronJob, and the s3 client.

This repository makes the following changes / enhancements, including:
* Added a Helm chart to create the OpenShift objects
* Added a shell script to bootstrap everything.
* Changed the S3 command to work with a third party S3 equivalent by using and endpoint URL instead of an S3 region.
* Fixed some potential race conditions.
* Updated the tolerations to make the CronJob work on some modern clusters.
* Various fixes, optimizations and updates to take advantage of things available 1.5 years after the blog post.

# Alternatives

OpenShift has a *Technology Preview* feature for recurring backups of etcd. However, it is *not ready for production* use, per the documentation. In particular, it requires enabling the `TechPreviewNoUpgrade` feature flag, which prevents upgrading OpenShift and *cannot be disabled*. So, don't use that feature for production clusters until it is ready.

# Prerequisites

1. The oc and helm binaries installed locally.
2. (Optional) The aws binary installed locally for verifying backups were uploaded.
2. An S3 provider, which can be AWS, or IBM Cloud Object Storage or an equivalent. A bucket will be created as part of the instructions.

# Install Instructions

## High Level Instructions

This procedure has multiple high level steps:

1. Create the IBM Cloud Object Storage credentials in Vaultwarden
2. Create the Application in ACM

## Set the S3 credential environment variables

Ideally these would be configured in Vaultwarden and imported into OpenShift using the External Secrets Operator, but that has not been tested in the lab yet. So, the install script will create a Secret.

To do this manually:

1. Stop sharing your screen :)
2. Run these commands, filling in your details

Note: Ensure the ENDPOINT_URL includes the protocol, e.g. https://...

```
export ENDPOINT_URL=<paste>
export AWS_ACCESS_KEY_ID=<paste>
export AWS_SECRET_ACCESS_KEY=<paste>
```

## Create an S3 bucket

An S3 bucket must exist, named `ocp-etcd-sync`.

You can do that from your S3 provider UI.

Or you can use the aws cli with:

```
aws s3 mb s3://ocp-etcd-sync \
  --endpoint-url ${ENDPOINT_URL} \
  --no-verify-ssl
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
* Run the Helm chart to create the objects in OpenShift, including a CronJob and a ServiceAccount

# Starting a backup now

Run a backup before and after every OpenShift install.

```
oc create job --from=cronjob/cronjob-etcd-backup manual-backup-$(date +%s) -n etcd-bkp
```

# Verifying the backups are working

Verify backup was created on the Node:

```
oc logs -n etcd-bkp -l app.kubernetes.io/name=cronjob-etcd-backup -c cronjob-etcd-backup
```

Verify the sync to S3 was successful:

```
oc logs -f -n etcd-bkp -l app.kubernetes.io/name=cronjob-etcd-backup -c aws-cli 
```

Verify the contents of S3:

```
aws s3 ls s3://ocp-etcd-sync/ --endpoint-url ${ENDPOINT_URL} --no-verify-ssl --recursive
```

# Restoring a backup

**WARNING:** This should be done only as a last resort! etcd restores are inherently risky. If you believe you need to do this, open a ticket with Red Hat Support.

Follow the official Red Hat instructions for restoring an etcd backup, here:

https://docs.redhat.com/en/documentation/openshift_container_platform/4.20/html/etcd/backing-up-and-restoring-etcd-data#etcd-dr-restore

They involve running a script called `cluster-restore.sh`.

