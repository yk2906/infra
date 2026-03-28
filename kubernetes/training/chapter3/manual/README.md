# 手書き演習（chapter3）

親の YAML は参照用。手順の詳細は [LAB.md](../LAB.md) も参照できるが、**マニフェスト本文は自分で書く**。

## 目標（段階的）

1. **ConfigMap** — キーを2つ以上（1つはファイル風の複数行でもよい）。  
2. **Secret** — `stringData` でユーザー名・パスワードなど（ダミーでよい）。  
3. **Deployment** — 上記を `env` または `volume` で参照（親の [deployment-with-config.yaml](../deployment-with-config.yaml) と名前を被らせない）。  
4. **PVC** — 環境の StorageClass に合わせて `storageClassName` を検討。  
5. **Deployment** — PVC を `/data` などにマウントし、データが残ることを確認（任意）。

## 命名

`manual-` プレフィックス推奨。

## 片付け

作成した順の逆や、`kubectl delete -f <ファイル>` で個別に削除。

## 答え合わせ

親ディレクトリの `configmap-app.yaml`、`secret-db.yaml`、`deployment-with-config.yaml`、`pvc.yaml`、`deployment-with-pvc.yaml` と比較する。
