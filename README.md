# Overview

Based on this blog post:

https://developers.redhat.com/articles/2024/09/26/enable-etcd-backups-openshift-clusters-hybrid-cloud-environments

# Instructions

## High Level Instructions

This procedure has multiple high level steps:

1. Give permissions to the service account
2. Create the IBM Cloud Object Storage credentials in Vaultwarden
3. Create the Application in ACM

## Give permissions to the service account

```
./install.sh
```

## Set the IBM Cloud Object Storage credentials

Ideally this would be done in vaultwarden, but that has not been tested in the lab.

To do this manually:

## Create the Application in ACM


