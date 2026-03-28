# 第6か月 — 総合課題チェックリスト

すべて `capstone-training` ネームスペースで説明・実演できることを目標にする。

## ワークロード

- [ ] Pod と Deployment の違いを説明できる
- [ ] `replicas` 変更とロールアウトの関係を説明できる
- [ ] `livenessProbe` / `readinessProbe` を追加し、挙動の差を説明できる

## ネットワーク

- [ ] Service の `selector` と Endpoints の対応を確認できる
- [ ] ClusterIP と（環境が許せば）NodePort / LoadBalancer の違いを説明できる
- [ ] Ingress でパス振り分けでき、Ingress コントローラの役割を説明できる

## 設定とシークレット

- [ ] ConfigMap を環境変数およびボリュームの両方で利用できる
- [ ] Secret を安全に扱う注意点（Git に平文を載せない等）を説明できる

## ストレージ

- [ ] PVC が `Bound` になるまでの流れ（SC / PV）を自分の環境で説明できる
- [ ] Pod 再作成後もデータが残るケースを確認した

## セキュリティ・運用

- [ ] ServiceAccount と Role / RoleBinding の最小権限の考え方を説明できる
- [ ] `kubectl logs` / `describe` / `events` で障害を切り分けられる

## 任意の次のステップ

- Helm / Kustomize で同一アプリを環境別に管理する
- HPA、ResourceQuota、NetworkPolicy
- CI から `kubectl apply` または GitOps（Argo CD 等）
