# 手書き演習（chapter4）

Ingress は環境依存が大きい。先に [NOTES.md](../NOTES.md) を読んでから、このディレクトリに手書きで作成する。

## 目標

1. **Ingress 1つ** — ホスト名は自分用（例: `manual.local`）。  
2. パス `/` と `/api`（または別パス）で、**既にクラスタにある2つの Service** に振り分ける。  
   - chapter2 の手書き演習で作った Service でも、親サンプルの Service でもよい。`backend` の名前は実在する Service に合わせること。  
3. （任意）**TLS** — [NOTES.md](../NOTES.md) の手順で Secret を作り、`tls` ブロック付き Ingress を手書き。

## 確認

`ingressClassName` は `kubectl get ingressclass` で環境に合わせて決める。

## 片付け

```bash
kubectl delete -f manual-ingress.yaml
```

## 答え合わせ

[ingress.yaml](../ingress.yaml)、[ingress-tls.yaml](../ingress-tls.yaml) と比較する。
