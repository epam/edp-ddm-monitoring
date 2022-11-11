#!/usr/bin/env bash

GRAFANA_NAMESPACE=$1
oc create namespace ${GRAFANA_NAMESPACE} || echo "Already exist"
oc -n ${GRAFANA_NAMESPACE} create sa ocp-prometheus || echo "already exist"
oc -n ${GRAFANA_NAMESPACE} adm policy add-cluster-role-to-user view -z ocp-prometheus || echo "already exist"
TOKEN=$(oc -n ${GRAFANA_NAMESPACE} get secrets -o name | grep ocp-prometheus-token | xargs -I{} oc -n ${GRAFANA_NAMESPACE} get {} -o=jsonpath={.data.token} | base64 --decode)
echo "-> Create OCP Prometheus datasource secret..."
cat << EOF > datasource-secret.yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: "https://prometheus-k8s.openshift-monitoring.svc:9091"
    basicAuth: false
    withCredentials: false
    isDefault: true
    version: 1
    editable: true
    jsonData:
      tlsSkipVerify: true
      timeInterval: "5s"
      httpHeaderName1: "Authorization"
    secureJsonData:
      httpHeaderValue1: "Bearer $TOKEN"
EOF
oc -n ${GRAFANA_NAMESPACE} create secret generic datasource-secret --from-file=datasource-secret.yaml || echo "already exist"
 oc -n ${GRAFANA_NAMESPACE} create secret generic grafana --from-literal=session_secret=fkoE6Cc9Zh1NgvXuVK1fFQhGT84FZom70nm5o2igRHG || echo "already exist"
