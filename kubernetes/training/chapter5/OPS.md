# chapter5 — 運用でよく使う kubectl コマンド一覧

## クラスタとコンテキスト

```bash
kubectl cluster-info
kubectl config get-contexts
kubectl config use-context <名前>
kubectl get nodes -o wide
```

## リソースの確認

```bash
kubectl get all
kubectl get pods,svc,deploy,ingress -A
kubectl describe pod <名前>
kubectl describe deployment <名前>
kubectl api-resources
kubectl explain pod.spec
```

## ログとシェル

```bash
kubectl logs <pod名>
kubectl logs -f deploy/<deployment名>
kubectl logs <pod名> -c <コンテナ名>
kubectl exec -it <pod名> -- /bin/sh
```

## デプロイとロールアウト

```bash
kubectl apply -f .
kubectl apply -f manifest.yaml --dry-run=client -o yaml
kubectl rollout status deployment/<名前>
kubectl rollout history deployment/<名前>
kubectl rollout undo deployment/<名前>
kubectl set image deployment/<名前> <コンテナ>=<イメージ:タグ>
```

## イベントとデバッグ

```bash
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl port-forward svc/<名前> 8080:80
kubectl auth can-i list pods --as=system:serviceaccount:default:study-viewer
```

## RBAC 確認の例

```bash
kubectl apply -f serviceaccount-viewer.yaml -f role-pod-reader.yaml -f rolebinding-pod-reader.yaml
kubectl auth can-i get pods --as=system:serviceaccount:default:study-viewer -n default
kubectl auth can-i delete pods --as=system:serviceaccount:default:study-viewer -n default
```

## メトリクス（metrics-server 導入済みの場合）

```bash
kubectl top nodes
kubectl top pods
```
