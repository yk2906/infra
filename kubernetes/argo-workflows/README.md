# Argo Workflows（UI で見るまで）

## ブラウザでSSOログイン（推奨・現在の構成）

`https://workflows.mamelly.com` にTailscale経由でアクセスし、Googleアカウントでログインできる。
port-forwardやトークンのコピペは不要。

### 前提

- ArgoCD側のIngress + Dex(Google OAuth)が設定済みであること（`kubernetes/argocd/README.md`）。
  Argo WorkflowsはArgoCDのDexを共通のOIDCプロバイダとして使う。
- Tailscaleで `workflows.mamelly.com` （k3sノードのTailscale IP）に到達できること。
- DNS: `infra/terraform/cloudflare/dns.tf` の `argo_workflows` レコード
  （Tailscale IPを指す、`proxied = false`）。

### Dex側の準備（argocd-cm / argocd-secret）

`kubernetes/argocd/README.md` の「SSO (Dex + Google OAuth)」を参照。
`argocd-cm`の`dex.config`に`staticClients`として以下を追加し、対応する
シークレットを`argocd-secret`の`dex.argoWorkflows.clientSecret`に登録する。

```yaml
staticClients:
  - id: argo-workflows
    name: Argo Workflows
    redirectURIs:
      - https://workflows.mamelly.com/oauth2/callback
    secret: $dex.argoWorkflows.clientSecret
```

### Argo Workflows側のSecret

Dexに登録したクライアントシークレットと同じ値を、`argo` namespaceの`argo-server-sso`
（Helmチャートのデフォルト名）に登録する。

```bash
kubectl create secret generic argo-server-sso -n argo \
  --from-literal=client-id=argo-workflows \
  --from-literal=client-secret="<dex.argoWorkflows.clientSecretと同じ値>"
```

### Helm values (`values-sso.yaml`)

`values-client-auth.yaml`と併用する。

```bash
helm upgrade --install argo-workflows argo/argo-workflows -n argo \
  -f kubernetes/argo-workflows/values-client-auth.yaml \
  -f kubernetes/argo-workflows/values-sso.yaml
```

ポイント:
- `server.secure: false` … IngressでTLS終端するため、serverはplain HTTPでlisten
- `server.authModes: [sso, client]` … ブラウザのSSOログインと、下記Bのトークン認証を両方有効化
- `server.sso.issuer: https://argocd.mamelly.com/api/dex` … ArgoCDのDexをOIDCプロバイダとして利用
- `server.sso.rbac.enabled: false` … SSOは「認証」のみ。認可はargo-server自身のSA権限に従う
  （Google OAuthクライアントが「テスト」モードのため、ログイン可能なのは登録済みテストユーザーのみ）

### Ingress

```bash
kubectl apply -f kubernetes/argo-workflows/ingress.yaml
```

`workflows.mamelly.com` → `argo-workflows-server:2746`、TLSは`letsencrypt-prod` ClusterIssuerで発行。

### 動作確認

`https://workflows.mamelly.com` を開き、「LOGIN」→GoogleアカウントでSSOログインできることを確認。

---

## (CLI/ServiceAccountトークンでアクセスする場合)

`argo submit`などCLIから操作する場合や、上記SSOを構成する前の確認用に、
client認証（ServiceAccountトークンのコピペ）の手順を以下に残す。

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

出力は **JWT そのもの**です。ログや共有に注意してください。

## C. UI へポートフォワード

Service 名は環境によります。`/2746` の Service を確認してから実行します。

```bash
kubectl get svc -n argo
kubectl -n argo port-forward svc/argo-workflows-server 2746:2746
```

`argo-workflows-server` が無い場合は、表示された UI 向け Service 名に合わせてください。

ブラウザの URL は **サーバの `--secure` に合わせる**必要があります。

このリポジトリの `values-client-auth.yaml` は **`server.secure: true`**（HTTPS）を前提にしています。

- **`https://localhost:2746/`** を開く（証明書は自己署名のため、ブラウザの警告から進む）
- **`--secure=false`** にしている場合のみ **http://localhost:2746/**

`--secure` は次で確認できます。

```bash
kubectl get deploy -n argo -l app.kubernetes.io/component=server \
  -o jsonpath='{range .items[*].spec.template.spec.containers[*].args[*]}{@}{"\n"}{end}' | grep -E 'secure|auth-mode'
```

## D. ログイン画面

- **Single Sign-On の LOGIN**：組織で OAuth などをセットアップ済みならこちら。未構成なら使えません。
- **Client Authentication**：**`Bearer `（末尾スペース含む）＋ JWT** を 1 行で貼り、**LOGIN**。

サーバ実装では、client モードのとき Cookie に格納される文字列が **`Bearer ` で始まる**必要があります（`Authorization: Bearer ...` と同じ形式）。**JWT だけ**を貼ると `token not valid` になることがあります。

貼り付けのコツ:

- 形式は次のとおり（1 行・末尾改行なし）。  
  `Bearer eyJhbGciOiJSUzI1NiIs...`  
  `kubectl create token` の結果の**前に**、手で `Bearer ` を付けます（先頭にスペースが入らないようにする）。
- **改行を入れない**（末尾 LF が混じると検証失敗しやすい）。

## トークンを貼っても進まないとき（切り分け）

### 1. Helm の「実際に効いている値」を確認する

`helm get values` の **USER-SUPPLIED** は、Chart 既定（例: `server.secure`）が表示されません。マージ結果も含めて見るなら例えば次です。

```bash
helm get values argo-workflows -n argo --all
```

続けて **`values-client-auth.yaml` を指して upgrade** し、server Pod が新しい args になったか確認してください。

### 2. サーバ Pod が本当に `--auth-mode=client` になっているか

`server.authModes` が反映されていない Pod が古いままだと、トークンで進みません。

```bash
kubectl get deploy -n argo -l app.kubernetes.io/component=server \
  -o jsonpath='{range .items[*].spec.template.spec.containers[*].args[*]}{@}{"\n"}{end}' | grep auth-mode
```

ここに **`--auth-mode=client`** が無い場合は、Helm の対象リリース名・namespace を間違えているか、別チャートが UI を提供している可能性があります。

### 3. curl でトークンが受理されるか（UI と別に検証）

ポートフォワードした状態で、**`--secure=true` のときは https と `-k`（自己署名）**:

```bash
TOKEN=$(kubectl create token argo-workflows-ui-viewer -n argo --duration=1h)
curl -sS -k -o /dev/null -w "HTTP %{http_code}\n" \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://127.0.0.1:2746/api/v1/info"
```

**Cookie で送る場合**は、値も **`Bearer ` 付き**にします（生 JWT のみだと 401 / `token not valid` になります）。

```bash
# printf で「Bearer 」と JWT をくっつけ、末尾改行なし
TOKEN=$(kubectl create token argo-workflows-ui-viewer -n argo --duration=1h)
curl -sS -k -w "\nHTTP %{http_code}\n" \
  --cookie "authorization=Bearer ${TOKEN}" \
  "https://127.0.0.1:2746/api/v1/userinfo"
```

`--secure=false` のときだけ URL を `http://127.0.0.1:2746` にし、`-k` は不要です。

- **401 / Unauthenticated** → 認証モードとトークン種別の不一致、`http`/`https` の取り違え、トークン不正のどれかが多いです。
- **200** → トークンは通っているので、**ブラウザで開いている URL（http/https）、キャッシュ、別タブの古いセッション**を疑ってください。

### 4. サーバのログに「token not valid for running mode」

[issue の議論](https://github.com/argoproj/argo-workflows/issues/5832) でも触れられているように、**サーバの `--auth-mode` と、渡している認証情報の種類が合っていない**と出やすいです。上記の **実 Pod の args** を優先して確認してください。

```bash
kubectl logs -n argo -l app.kubernetes.io/component=server --tail=80
```

### 5. 参考リンク

- [Argo Server auth mode](https://argo-workflows.readthedocs.io/en/stable/argo-server-auth-mode/)
- [Access token（ServiceAccount 前提の流れ）](https://argo-workflows.readthedocs.io/en/stable/access-token/)

## 練習: 公開 API → Discord / Slack Incoming Webhook（app の実行スクリプト）

処理は **`~/work/app/workflow-demo/fetch_and_notify.py`** にあり、コンテナビルド用は同ディレクトリの `Dockerfile`。CI で **GHCR** に push する場合は app リポジトリの `.github/workflows/workflow-demo.yaml`（`workflow-demo/**` 変更時）を利用する。

1. **Secret**（Webhook URL。コミットしない）

```bash
cp kubernetes/argo-workflows/secret-notify-webhooks.example.yaml kubernetes/argo-workflows/secret-notify-webhooks.local.yaml
# 編集後
kubectl apply -f kubernetes/argo-workflows/secret-notify-webhooks.local.yaml
```

2. **イメージ**  
   `demo-api-notify-workflow.yaml` のパラメータ **`workflow-demo-image`**（既定 `ghcr.io/yk2906/workflow-demo:latest`）を、自分のレジストリ／タグに合わせる。初回は app を push するか手元で `docker build` + `docker push` してイメージを用意する。

3. **Workflow 実行**（`serviceAccountName: argo-workflow` 前提）

```bash
kubectl create -f kubernetes/argo-workflows/demo-api-notify-workflow.yaml -n argo
```

Slack に送る場合はマニフェストの `provider` を `slack` にするか、`argo submit ... -p provider=slack`。イメージだけ差し替えるなら `argo submit ... -p workflow-demo-image=...`。

既定の `api-url` は **`https://httpbin.org/get`**。遮断される場合は `api-url` を変更する。

最小の単一ステップ例は `hello-workflow.yaml` です。

## ワークフローを「操作」までしたい場合

`verbs` に `create` / `update` / `delete` が必要になります。閲覧専用の `rbac-ui-viewer.yaml` は意図的に絞っているため、その場合は別ロール設計または一時的に権限広めの環境のみで運用することを検討してください。
