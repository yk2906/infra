# 社内学習用 Kubernetes ハンズオン

6か月で Kubernetes の基礎を一通り扱うためのマニフェストと章立てです。各月は「概念 → `kubectl` 操作 → マニフェスト適用 → 片付け」の流れで進めると定着しやすいです。

各章の **`manual/`** は、親ディレクトリのサンプルを**答え合わせ用に残したまま**、マニフェストを**手で書く練習場**です。手順と目標は各 [chapterN/manual/README.md](chapter1/manual/README.md) に記載しています。

## 環境前提（ハンズオン前に確認）

| 項目 | メモ |
|------|------|
| クラスタ | kind / k3s / マネージド（EKS・GKE・AKS 等）のいずれか。`kubectl cluster-info` と `kubectl get nodes` が通ること。 |
| kubectl | クライアントとクラスタのバージョン差が大きすぎないこと（公式のバージョン差ポリシーを参照）。 |
| ネームスペース | 演習用に `kubectl create namespace training` などを切ってもよい。サンプルは多くが `default` 想定。 |
| 第4章以降 | **Ingress コントローラ**、**StorageClass**、**LoadBalancer** の有無は環境依存。[chapter4/NOTES.md](chapter4/NOTES.md) を必ず読む。 |

## 6か月の目次とフォルダ対応

| 月 | テーマ | フォルダ・資料 |
|----|--------|----------------|
| 1 | クラスタの触り方、`kubectl`、Pod | [chapter1/](chapter1/) |
| 2 | Deployment、ロールアウト、Service | [chapter1/](chapter1/)（Deployment）+ [chapter2/](chapter2/) |
| 3 | ConfigMap、Secret、ボリューム、PVC | [chapter3/](chapter3/) |
| 4 | Ingress、外部公開 | [chapter4/](chapter4/) |
| 5 | Probe、RBAC、運用コマンド | [chapter5/](chapter5/) |
| 6 | 総合課題・振り返り | [chapter6/](chapter6/) |

## 章一覧（クイックリンク）

- [chapter1 — Pod・Deployment](chapter1/)
- [chapter2 — Service・複数 Deployment](chapter2/)
- [chapter3 — ConfigMap・Secret・PVC](chapter3/)
- [chapter4 — Ingress・TLS（環境メモ付き）](chapter4/)
- [chapter5 — Probe・RBAC・運用コマンド](chapter5/)
- [chapter6 — 総合課題の骨子とチェックリスト](chapter6/)

### 手書き演習（`manual/`）

- [chapter1/manual](chapter1/manual/) · [chapter2/manual](chapter2/manual/) · [chapter3/manual](chapter3/manual/) · [chapter4/manual](chapter4/manual/) · [chapter5/manual](chapter5/manual/) · [chapter6/manual](chapter6/)

## 片付けの例

```bash
kubectl delete -f path/to/manifest.yaml
# またはリソース種別ごとに削除（演習で作成したラベルに合わせて調整）
kubectl delete deployment,service --selector=app=example-app
```
