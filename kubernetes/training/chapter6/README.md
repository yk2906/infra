# chapter6 — 総合課題の骨子

- [manual/](manual/) — 手書き演習（別ネームスペースで総合構成を自分で書く）

ミニアプリ想定の **プレースホルダ** です。イメージ・Probe・Secret 参照・PVC マウント・TLS などを [CHECKLIST.md](CHECKLIST.md) に沿って足していく。

## 適用順の例

```bash
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml -f secret.yaml
# pvc.yaml は StorageClass 設定後に apply
kubectl apply -f pvc.yaml
kubectl apply -f deployment-web.yaml -f deployment-api.yaml
kubectl apply -f service-web.yaml -f service-api.yaml
kubectl apply -f ingress.yaml
```

Ingress を使う前に [chapter4/NOTES.md](../chapter4/NOTES.md) で環境を確認する。

## 片付け

```bash
kubectl delete namespace capstone-training
```
