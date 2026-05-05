# Argo Workflows（UI で見るまで）

ブラウザで UI を見るときの流れは **(A) Helm で client 認証を有効化** → **(B) 閲覧用 ServiceAccount とトークン発行** → **(C) ポートフォワード** → **(D) 画面の「Client Authentication」にトークンを貼る** が一般的です。

## 前提

- `kubectl` がクラスタに接続できていること
- Helm で `argo/argo-workflows` を `-n argo`（など）にインストール済みであること
- 環境により **namespace は `argo` 以外**になる場合があります。その場合は以降の `argo` を置き換えてください。
- Helm リリース名や Service 名は `helm list -n argo`、`kubectl get svc -n argo` で確認してください（多くは `2746/tcp` が UI）。

## A. Client 認証を有効化（認証済み構成なら省略可）

```bash
helm upgrade --install argo-workflows argo/argo-workflows \
  -n argo \
  --create-namespace \
  -f kubernetes/argo-workflows/values-client-auth.yaml
```

サーバー Pod が再起動したら、`kubectl rollout status deployment -n argo -l app.kubernetes.io/component=server` などで落ち着くまで待ちます。

## B. UI 閲覧用のアカウントとトークン

このリポジトリの RBAC と ServiceAccount を入れます。

```bash
kubectl apply -f kubernetes/argo-workflows/rbac-ui-viewer.yaml
```

トークン（例: 24 時間。Kubernetes 1.24+ で `kubectl create token` が使える前提）。

```bash
kubectl create token argo-workflows-ui-viewer -n argo --duration=24h
```

出力される **JWT だけ** をコピーします（ログや共有に注意）。

## C. UI へポートフォワード

Service 名は環境によります。`/2746` の Service を確認してから実行します。

```bash
kubectl get svc -n argo
kubectl -n argo port-forward svc/argo-workflows-server 2746:2746
```

`argo-workflows-server` が無い場合は、表示された UI 向け Service 名に合わせてください。

ブラウザで **https://localhost:2746/** を開きます（証明書警告は開発時は「続行」でよいことが多いです）。

## D. ログイン画面

- **Single Sign-On の LOGIN**：組織で OAuth などをセットアップ済みならこちら。未構成なら使えません。
- **Client Authentication**：上で発行したトークンをテキストボックスに貼り、**LOGIN**。

## SSO だけが目立っている／トークンを貼っても進めないとき

まず **`values-client-auth.yaml` を適用した upgrade** と、認証関連の現在値を確認します。

```bash
helm get values argo-workflows -n argo
```

問題が続くときは、[Argo Workflows の Server の auth mode ドキュメント](https://argo-workflows.readthedocs.io/en/stable/argo-server-auth-mode/) を参照してください。

## ワークフローを「操作」までしたい場合

`verbs` に `create` / `update` / `delete` が必要になります。閲覧専用の `rbac-ui-viewer.yaml` は意図的に絞っているため、その場合は別ロール設計または一時的に権限広めの環境のみで運用することを検討してください。
