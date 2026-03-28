# chapter2 — Service と複数 Deployment

- [manual/](manual/) — 手書き演習（Deployment×2 と Service×2）

## 適用順の例

```bash
kubectl apply -f deployment-frontend.yaml
kubectl apply -f deployment-backend.yaml
kubectl apply -f service-frontend.yaml
kubectl apply -f service-backend.yaml
```

## 演習のヒント

- `kubectl get endpoints` で Service と Pod の対応を確認する。
- `kubectl rollout status deployment/study-frontend` とイメージ変更後の `kubectl rollout undo` を試す。
- 一時的に `NodePort` に変更し、ノードIPとポートから疎通する（環境が許す場合）。
