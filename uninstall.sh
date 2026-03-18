set -euo pipefail
set -x

oc delete project etcd-bkp
oc adm policy remove-scc-from-user privileged -z openshift-backup

