# chapter4 — 環境別メモ（Ingress / TLS）

## 事前条件

- [chapter2](../chapter2/) の Deployment と Service が同一ネームスペースに存在すること。
- クラスタに **Ingress コントローラ** が入っていること（なければ HTTP ルーティングは動かない）。

## kind

1. クラスタ作成時に [Ingress NGINX](https://kind.sigs.k8s.io/docs/user/ingress/) の手順に従いコントローラを導入する。
2. `kubectl port-forward` で Ingress Controller の Service に転送するか、`extraPortMappings` でホストから 80/443 を叩けるようにする。
3. `ingress.yaml` の `host: demo.local` を `/etc/hosts` で `127.0.0.1` に向ける（port-forward 利用時）。

## k3s

- Traefik が有効な場合が多い。`ingressClassName` を Traefik 用に変えるか、クラスタのデフォルト IngressClass を `kubectl get ingressclass` で確認する。
- ローカル向け IP はノードの IP。LoadBalancer が無い場合は Service の NodePort や kube-proxy 経由の説明に合わせて教材を補足する。

## マネージド（EKS / GKE / AKS 等）

- コントローラ（ALB Ingress / GKE Ingress / Application Gateway 等）ごとに **annotations が必須** なことが多い。公式ドキュメントのサンプルと突き合わせる。
- `LoadBalancer` 型 Service と Ingress の使い分け（L4 と L7）を整理してから演習すると理解しやすい。

## TLS 最小例（自己署名・ローカル検証）

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt -subj "/CN=demo.local" \
  -addext "subjectAltName=DNS:demo.local"

kubectl create secret tls tls-demo-secret --cert=tls.crt --key=tls.key
kubectl apply -f ingress-tls.yaml
```

ブラウザは自己署名の警告を出す。本番では ACME（cert-manager 等）やクラウドのマネージド証明書を使う。

## ingressClassName について

サンプルでは `nginx` を記載している。**環境の IngressClass 名に合わせて変更**するか、未指定でデフォルトに任せる場合は `spec.ingressClassName` 行を削除し、コントローラ側のデフォルト設定に依存する（クラスタ設定による）。
