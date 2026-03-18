#!/bin/bash
set -euo pipefail

NAMESPACE=etcd-bkp

# Check that AWS environment variables are set
REQUIRED_VARS=(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY ENDPOINT_URL)
MISSING_VARS=()
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var:-}" ]]; then
		MISSING_VARS+=("$var")
	fi
done

if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
	echo "ERROR: You must set these environment variables:"
	for missing in "${MISSING_VARS[@]}"; do
		echo " - $missing"
	done
	exit 1
fi

set -x

# Create project if it does not exist
if ! oc get project "${NAMESPACE}" &> /dev/null; then
	oc new-project "${NAMESPACE}"
fi

# Allow the openshift-backup ServiceAccount to run privileged Pods
oc adm policy add-scc-to-user privileged -z openshift-backup -n ${NAMESPACE}

# Create or update the secret with the S3 credentials
oc create secret generic aws-s3-etcd-key \
	--from-literal=aws_access_key_id=${AWS_ACCESS_KEY_ID} \
	--from-literal=aws_secret_access_key=${AWS_SECRET_ACCESS_KEY} \
	--from-literal=endpoint_url=${ENDPOINT_URL} \
	-n ${NAMESPACE} \
	--dry-run=client -o yaml | oc apply -f -

echo "Done."
