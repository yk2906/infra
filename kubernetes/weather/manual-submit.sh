#!/usr/bin/env bash
# CronWorkflow weather-tomorrow-forecast を手動で 1 回実行する（argo CLI 不要）
set -euo pipefail

NAMESPACE="${NAMESPACE:-weather}"
CRONWF="${CRONWF:-weather-tomorrow-forecast}"

if ! command -v kubectl >/dev/null; then
  echo "kubectl が見つかりません" >&2
  exit 1
fi

if ! command -v jq >/dev/null; then
  echo "jq が見つかりません。インストール: sudo apt install jq" >&2
  exit 1
fi

kubectl get cronworkflow "$CRONWF" -n "$NAMESPACE" -o json \
  | jq '{
      apiVersion: "argoproj.io/v1alpha1",
      kind: "Workflow",
      metadata: {
        generateName: (.metadata.name + "-manual-"),
        namespace: .metadata.namespace,
        labels: (.metadata.labels // {})
      },
      spec: .spec.workflowSpec
    }' \
  | kubectl create -f -

echo "Workflow を作成しました。確認: kubectl get workflows -n ${NAMESPACE}"
