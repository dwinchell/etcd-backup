set -euo pipefail
set -x

source config.sh

helm uninstall ${HELM_RELEASE_NAME} .
oc delete project ${NAMESPACE}
oc adm policy remove-scc-from-user privileged -z ${SERVICE_ACCOUNT} -n ${NAMESPACE}
