#!/bin/bash
# Installs all ida helm charts 
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=ida
CHART_VERSION=12.0.2

echo Create $NS namespace
kubectl create ns $NS

function installing_ida() {
  echo Istio label
  kubectl label ns $NS istio-injection=enabled --overwrite
  helm repo update

  echo Copy configmaps
  sed -i 's/\r$//' copy_cm.sh
  ./copy_cm.sh

  echo Running ida keygen
  helm -n $NS install ida-keygen mosip/keygen --wait --wait-for-jobs --set image.repository=mosipdev/keys-generator  --version $CHART_VERSION -f keygen_values.yaml

  echo Installing ida auth
  helm -n $NS install ida-auth mosip/ida-auth --set image.repository=mosipdev/authentication-service  --version $CHART_VERSION

  echo Installing ida internal
  helm -n $NS install ida-internal mosip/ida-internal --set image.repository=mosipdev/authentication-internal-service  --version $CHART_VERSION

  echo Installing ida otp
  helm -n $NS install ida-otp mosip/ida-otp --set image.repository=mosipdev/authentication-otp-service  --version $CHART_VERSION

  kubectl -n $NS  get deploy -o name |  xargs -n1 -t  kubectl -n $NS rollout status

  echo Installed ida services
  return 0
}

# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes
installing_ida   # calling function
