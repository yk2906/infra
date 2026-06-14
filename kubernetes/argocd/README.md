# ArgoCD: Ingress + SSO(Google) でブラウザログイン

毎回のシークレット発行・port-forwardをやめて、`https://argocd.mamelly.com` にTailscale経由でアクセスし、
Googleアカウントでログインできるようにする構成。

## 前提（アクセス経路）

- このIngressは**インターネットには公開していない**。アクセスできるのはTailscaleのtailnetに
  参加している端末のみ。
- k3sノード（`dev-instance-0101z`）にTailscaleを導入し、割り当てられたTailscale IP
  （例: `100.86.157.73`）を確認する。
  ```bash
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo tailscale up
  tailscale ip -4
  ```
- ブラウザを使う端末（Windows/WSLなど）も同じtailnetに参加させる。

## DNS

`infra/terraform/cloudflare/dns.tf` に、上記Tailscale IPを指すAレコードを追加済み
（`proxied = false`。CloudflareのProxy経由ではTailscaleのCGNAT帯IPに到達できないため）。

```hcl
resource "cloudflare_record" "argocd" {
  name    = "argocd"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.86.157.73"  # k3sノードのTailscale IP
  zone_id = "f8d0ddf4c963e35e758c7d49b81f6fb4"
}
```

## Ingress

`ingress.yaml` で `argocd.mamelly.com` → `argocd-server` Service(port `http`=8080)へルーティングし、
cert-managerの`letsencrypt-prod` ClusterIssuerでTLS証明書を発行する。

ArgoCDサーバーはデフォルトで自己署名HTTPS(8080)を喋るため、IngressでTLS終端する構成に合わせて
`argocd-cmd-params-cm`に`server.insecure: "true"`を設定し、plain HTTPに変更している。

```bash
kubectl patch cm argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd
kubectl apply -f kubernetes/argocd/ingress.yaml
```

## SSO (Dex + Google OAuth)

ArgoCDには標準で`argocd-dex-server`が同梱されている。これにGoogleの connector を設定する。

### 1. Google Cloud Console

- OAuth同意画面: 外部 / テストモード（テストユーザーに自分のGoogleアカウントを追加）
- OAuthクライアントID（ウェブアプリケーション）を作成
  - 承認済みリダイレクトURI: `https://argocd.mamelly.com/api/dex/callback`

> **テストモードのまま運用する理由**: 「テスト」状態のOAuthクライアントは、登録した
> テストユーザー以外はログインを完了できない。これが実質的な「自分しかログインできない」
> アクセス制御として機能する（Tailscaleのtailnet参加と合わせて二重の制御になる）。

### 2. argocd-cm: dex.config

```yaml
url: https://argocd.mamelly.com
dex.config: |
  connectors:
    - type: google
      id: google
      name: Google
      config:
        clientID: <Google OAuthクライアントID>
        clientSecret: $dex.google.clientSecret
        redirectURI: https://argocd.mamelly.com/api/dex/callback
  staticClients:
    - id: argo-workflows
      name: Argo Workflows
      redirectURIs:
        - https://workflows.mamelly.com/oauth2/callback
      secret: $dex.argoWorkflows.clientSecret
```

`staticClients`の`argo-workflows`は、Argo Workflowsが「ArgoCDのDex」をOIDCプロバイダとして
利用するための設定（後述）。

### 3. argocd-secret にクライアントシークレットを登録

```bash
# Google OAuthクライアントシークレット
kubectl patch secret argocd-secret -n argocd --type merge \
  -p '{"stringData":{"dex.google.clientSecret":"<Googleのクライアントシークレット>"}}'

# Argo Workflows用の内部シークレット（自分で生成。Dex⇔Argo Workflows間のみで使う）
SECRET=$(openssl rand -hex 32)
kubectl patch secret argocd-secret -n argocd --type merge \
  -p "{\"stringData\":{\"dex.argoWorkflows.clientSecret\":\"$SECRET\"}}"
# 同じ値を argo namespace の argo-server-sso Secret にも登録する（argo-workflows/README.md参照）
```

### 4. RBAC (argocd-rbac-cm)

自分のGoogleアカウントに管理者権限を付与する。

```yaml
policy.default: ""
policy.csv: |
  g, yk050696@gmail.com, role:admin
scopes: '[groups, email]'
```

> **`scopes`が必須の理由**: ArgoCD RBACはデフォルトで`groups`クレームのみを`g`行の
> マッピング対象にする。GoogleのDexコネクタは`groups`クレームを返さないため、
> `scopes`に`email`を追加しないと`g, <email>, role:admin`が一致せず、
> ログインしても権限なし（Application一覧が空）になる。

### 5. 反映

```bash
kubectl rollout restart deployment argocd-dex-server argocd-server -n argocd
```

## 動作確認

`https://argocd.mamelly.com` を開き、「LOG IN VIA GOOGLE」からGoogleアカウントでログインできることを確認。

## 検討した代替案: IPAllowList Middleware

当初、Traefikの`IPAllowList` Middlewareで自宅の固定IPからのみアクセスを許可する案も検討したが、
k3sのLoadBalancer実装(klipper-lb/svclb)がリクエストをMASQUERADEするため、Traefikからは
本来のクライアントIPが見えず（常にPod CIDR内のIPになる）、機能しないことが分かった。

→ Tailscaleのtailnetメンバーシップ（ネットワーク層）+ SSO(アプリ層)の二重防御で代替している。
