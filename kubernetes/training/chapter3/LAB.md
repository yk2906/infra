# chapter3 演習手順メモ

手書きでマニフェストを作る場合は、[manual/README.md](manual/README.md) の目標に沿って `manual/` 以下に YAML を置き、以下の手順はファイル名を読み替えて使う。

## 1. ConfigMap と Secret を Deployment に載せる

1. `kubectl apply -f configmap-app.yaml -f secret-db.yaml`
2. `kubectl apply -f deployment-with-config.yaml`
3. Pod を特定して次を実行する。
   - `kubectl exec -it deploy/study-app-with-config -- printenv | grep -E 'DB_|APP_'`
   - `kubectl exec -it deploy/study-app-with-config -- cat /etc/config/greeting.txt`
4. ConfigMap を `kubectl edit configmap study-app-config` で変更し、ロールアウトまたは Pod 再起動後に反映を確認する（`subPath` 未使用の場合の挙動も調べる）。

## 2. PVC とストレージ

1. クラスタで `kubectl get storageclass` を実行し、利用可能な StorageClass を確認する。
2. `pvc.yaml` の `storageClassName` を必要に応じて追記する。
3. `kubectl apply -f pvc.yaml` のあと `kubectl get pvc` で `Bound` になるまで待つ。
4. `kubectl apply -f deployment-with-pvc.yaml`
5. `kubectl exec` で `/data/out.log` を確認し、Pod を削除して再作成してもファイルが残るか検証する（`replicas: 1` で別ノードに飛ぶと環境によっては注意）。

## 片付け

```bash
kubectl delete -f deployment-with-pvc.yaml -f deployment-with-config.yaml
kubectl delete -f pvc.yaml -f secret-db.yaml -f configmap-app.yaml
```

PVC を消すと環境によっては PV のデータも削除される。共有クラスタでは管理者に確認する。
