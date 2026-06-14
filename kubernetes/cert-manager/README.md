# cert-manager + Cloudflare DNS-01

ArgoCD / Argo Workflows をTailscale経由の非公開構成で、正規のLet's Encrypt証明書を使ってHTTPS化するためのセットアップ。

## 構成

- `mamelly.com` のDNSはCloudflareで管理（`infra/terraform/cloudflare`）。
- cert-managerが **DNS-01チャレンジ**（CloudflareのAPIでTXTレコードを一時作成）でドメイン所有を証明し、Let's Encryptから証明書を取得する。
- DNS-01を使うため、クラスタをインターネットに公開する必要がない（HTTP-01のようにポート80を外部公開しなくてよい）。

## 導入手順

### 1. cert-manager本体

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack
helm install cert-manager jetstack/cert-manager -n cert-manager --create-namespace --set crds.enabled=true
```

### 2. CloudflareのAPIトークンをSecretに登録

`infra/terraform/cloudflare/secret.tfvars` の `cloudflare_api_token`（Zone:DNS:Edit権限を持つトークン）を再利用する。

```bash
TOKEN=$(grep cloudflare_api_token infra/terraform/cloudflare/secret.tfvars | sed -E 's/.*=\s*"(.*)"/\1/')
kubectl create secret generic cloudflare-api-token-secret -n cert-manager --from-literal=api-token="$TOKEN"
unset TOKEN
```

### 3. ClusterIssuer

- `clusterissuer-letsencrypt-staging.yaml`: 動作確認用（Let's Encrypt staging環境）。まずこれでDNS-01が通ることを確認する。
- `clusterissuer-letsencrypt-prod.yaml`: 本番用。Ingressの`cert-manager.io/cluster-issuer`アノテーションで指定する。

```bash
kubectl apply -f kubernetes/cert-manager/clusterissuer-letsencrypt-staging.yaml
kubectl apply -f kubernetes/cert-manager/clusterissuer-letsencrypt-prod.yaml
```

両方とも `selector.dnsZones: [mamelly.com]` を指定し、Cloudflareトークンを参照する。

## 動作確認のやり方

テスト用の`Certificate`を作って `kubectl get challenge -n <ns>` の `STATE` が `pending` → `valid` → Certificateの`READY`が`True`になれば成功。

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test-tls
  namespace: argocd
spec:
  secretName: test-tls
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
  dnsNames:
    - argocd.mamelly.com
```

確認後は `kubectl delete certificate test-tls -n argocd && kubectl delete secret test-tls -n argocd` で削除する。

## トラブルシュート

- `kubectl get challenge -A` でチャレンジの状態・エラーを確認
- `kubectl describe certificate <name> -n <ns>` でCertificateのイベントを確認
- DNS-01は伝播待ちで1〜2分かかることがある（`Waiting for DNS-01 challenge propagation` は正常）
