# 手書き演習（chapter1）

親ディレクトリのサンプルは**参照用（答え合わせ）**です。まずは見ずに、この `manual/` 以下に自分用の YAML を新規作成してから `kubectl apply` してください。

## 目標

1. **Pod**  
   - 任意の名前の Pod を1つ（コンテナは `nginx` などでよい）。  
   - `apiVersion` / `kind` / `metadata` / `spec` をすべてキーボードから入力する。

2. **Deployment**（余力があれば）  
   - `replicas`、`selector.matchLabels`、`template.metadata.labels` の対応が取れること。  
   - 親の [deployment.yaml](../deployment.yaml) と**名前やラベルが被らない**ようにする（例: `manual-` プレフィックス）。

## 推奨ファイル名（例）

- `my-pod.yaml`
- `my-deployment.yaml`

## 片付け

```bash
kubectl delete -f my-pod.yaml
kubectl delete -f my-deployment.yaml
```

## 答え合わせ

迷ったら [pod.yaml](../pod.yaml) と [deployment.yaml](../deployment.yaml) と diff する。
