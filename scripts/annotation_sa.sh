#!/usr/bin/env bash

GRAFANA_NAMESPACE=$1
dnsWildcard=$(oc get --namespace=openshift-ingress-operator ingresscontroller/default -o 'jsonpath={.status.domain}')
oc -n "${GRAFANA_NAMESPACE}" annotate serviceaccount grafana serviceaccounts.openshift.io/oauth-redirectreference.grafana='{"kind":"OAuthRedirectReference","apiVersion":"v1","reference":{"kind":"Route","name":"grafana"}}' --overwrite