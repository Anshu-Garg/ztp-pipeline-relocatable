#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -m

# variables
# #########
source ./common.sh ${1}

if [ $(oc get ns | grep ${REGISTRY} | wc -l) -eq 0 ]; then
	oc create ns ${REGISTRY}
fi

export REGISTRY_NAME="$(oc get route -n openshift-image-registry default-route -o jsonpath={'.status.ingress[0].host'})"
podman login ${DESTINATION_REGISTRY} -u ${REG_US} -p ${REG_PASS} --authfile=${PULL_SECRET} # to create a merge with the registry original adding the registry auth entry

echo ">>>> Mirror Openshift Version"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
oc adm release mirror -a ${PULL_SECRET} --from="${OPENSHIFT_RELEASE_IMAGE}" --to-release-image="${OCP_DESTINATION_INDEX}" --to="${DESTINATION_REGISTRY}/${OCP_DESTINATION_REGISTRY_IMAGE_NS}"
