set -euo pipefail
set -x

NAMESPACE=etcd-bkp

oc new-project ${NAMESPACE}
oc adm policy add-scc-to-user privileged -z openshift-backup
oc create secret generic aws-s3-etcd-key --from-literal=aws_access_key_id=${AWS_ACCESS_KEY_ID} --from-literal=aws_secret_access_key=${AWS_SECRET_ACCESS_KEY} --from-literal=endpoint_url=${ENDPOINT_URL} -n ${NAMESPACE}

