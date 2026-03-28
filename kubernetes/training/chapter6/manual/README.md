# 手書き演習（chapter6）

親の骨子（`namespace.yaml` など）は**答えの一例**です。総合課題は、可能なら **親を閉じた状態**から、この `manual/` にすべてのマニフェストを手書きする。

## 目標

[CHECKLIST.md](../CHECKLIST.md) の項目を満たす最小構成を、**別ネームスペース**（例: `manual-capstone`）で自分の名前付けで組む。

含める想定:

- Namespace
- ConfigMap / Secret（ダミー可）
- Deployment 2つ以上（web / api など役割が分かればよい）
- それぞれの Service
- PVC とそれをマウントするワークロード（1つでよい）
- Ingress（環境が許す場合）

## 運用

- ファイル分割は自由（1ファイルにまとめてもよい）。  
- 親の `capstone-training` と名前が被らないようにする。

## 片付け

```bash
kubectl delete namespace manual-capstone
```

（実際の Namespace 名に合わせて変更）

## 答え合わせ

構成やフィールドの抜けを [CHECKLIST.md](../CHECKLIST.md) と親ディレクトリの YAML で確認する。
