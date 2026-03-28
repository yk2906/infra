# 手書き演習（chapter2）

親のマニフェストは参照用です。**まず手書き**で、次をこのディレクトリに作成してください。

## 目標

1. **Deployment を2つ**（フロント用・バックエンド用など、役割が分かるラベルで区別）。  
2. それぞれに対応する **ClusterIP Service** を2つ（`selector` が各 Deployment の Pod ラベルと一致）。

## 命名のヒント

親サンプル（`study-frontend` 等）と衝突しないよう、リソース名は `manual-` で始めるとよい。

## 確認コマンド（例）

```bash
kubectl get deploy,svc,pods -l app=manual-frontend
kubectl get endpoints
```

## 片付け

作成したファイルを指定して削除する。

```bash
kubectl delete -f .
```

## 答え合わせ

[deployment-frontend.yaml](../deployment-frontend.yaml) などと比較する。
