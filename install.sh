set -euo pipefail
set -x

oc new-project etcd-bkp
oc adm policy add-scc-to-user privileged -z openshift-backup

