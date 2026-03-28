# 手書き演習（chapter5）

## 目標

1. **Deployment** — `livenessProbe` と `readinessProbe` を**キーボードから**書く（`httpGet` でよい）。必要なら `startupProbe` も。  
2. **RBAC** — 次を3ファイルに分けても1ファイルでもよい。  
   - `ServiceAccount`（名前は `manual-` で始める）  
   - `Role` — 同一ネームスペース内で `pods` の `get,list,watch` のみ  
   - `RoleBinding` — 上記 SA に Role を付与  

## 確認

[OPS.md](../OPS.md) の `kubectl auth can-i` の例を、自分の SA 名に置き換えて試す。

## 片付け

```bash
kubectl delete -f .
```

## 答え合わせ

[deployment-probes.yaml](../deployment-probes.yaml)、[serviceaccount-viewer.yaml](../serviceaccount-viewer.yaml)、[role-pod-reader.yaml](../role-pod-reader.yaml)、[rolebinding-pod-reader.yaml](../rolebinding-pod-reader.yaml) と比較する。
