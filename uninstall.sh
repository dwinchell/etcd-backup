set -euo pipefail
set -x

oc delete project etcd-bkp
oc adm policy remove-scc-to-user privileged -z openshift-backup

