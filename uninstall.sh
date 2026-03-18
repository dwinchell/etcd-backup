set -euo pipefail
#set -x

source config.sh

# Uninstall the Helm chart
echo "Uninstalling Helm release, if present ..."
helm uninstall "${HELM_RELEASE_NAME}" 2>/dev/null || true

# Delete cluster-scoped resources that Helm might miss
echo "Deleting cluster scoped resources, if present ..."
oc delete clusterrole cronjob-etcd-bkp-cr --ignore-not-found
oc delete clusterrolebinding cronjob-etcd-bkp-crb --ignore-not-found

# Revert policy change to allow service account to run privileged containers
echo "Reverting policy change, if present..."
oc adm policy remove-scc-from-user privileged -z ${SERVICE_ACCOUNT} -n ${NAMESPACE} 2>/dev/null || true

echo "Deleting namespace, if present ..."
oc delete project ${NAMESPACE} 2>/dev/null --ignore-not-found

echo "Uninstall finished."

