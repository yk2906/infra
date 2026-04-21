# infra

インフラストラクチャの定義・運用スクリプトをまとめたリポジトリです。  
Ansible / Kubernetes / Terraform / 補助スクリプトを中心に、クラウド・学習環境の構築と運用に利用します。

## 概要

- **Ansible**: Linux 初期設定（`setup-linux.yml`）、kind / k3s、CLI ツール（roles 経由）、Argo CD / Helm / Prometheus のセットアップ
- **Kubernetes**: `steam-bot` / `dummy` / `training` 用マニフェスト
- **Terraform**: AWS / GCP / OCI / test 用の IaC 定義
- **Script**: AWS CLI を使った EC2 起動・停止・情報取得スクリプト
- **Cloudflare**: 設定用ディレクトリ（プレースホルダ）

## ディレクトリ構成

```
infra/
├── README.md           # このファイル
├── ansible/            # Ansible playbooks（kind / ArgoCD / Helm / Prometheus 等）
├── cloudflare/         # Cloudflare 関連
├── kubernetes/         # Kubernetes マニフェスト（steam-bot / dummy / training）
├── script/             # EC2 操作用スクリプト
└── terraform/          # Terraform 定義（aws / gcp / oci / test）
```

## EC2 スクリプト（AWS CLI）

AWS CLI が設定済みであることを前提に、EC2 の操作を行います。

### インスタンス一覧の取得

```bash
./script/get_ec2_id.sh
```

- 全 EC2 の **InstanceId** と **PublicIpAddress** をテキストで出力します。

### インスタンスの起動

```bash
./script/start_ec2.sh <インスタンスID> [インスタンスID ...]
```

例:

```bash
./script/start_ec2.sh i-05f688f88e7906c22
```

### インスタンスの停止

```bash
./script/stop_ec2.sh <インスタンスID> [インスタンスID ...]
```

例:

```bash
./script/stop_ec2.sh i-05f688f88e7906c22
```

**注意:** 各スクリプトは `aws` コマンドを利用するため、事前に `aws configure` などで認証情報を設定してください。

## 各ディレクトリの説明

| ディレクトリ | 説明 |
|-------------|------|
| **script/** | AWS CLI を用いた EC2 操作用スクリプト（起動・停止・一覧取得）。 |
| **ansible/** | kind/K3s 学習環境の構築、ArgoCD / Helm / Prometheus のインストール、Linux セットアップ。詳細は [ansible/README.md](ansible/README.md) を参照。 |
| **kubernetes/** | `steam-bot` / `dummy` / `training` の Kubernetes マニフェスト。`steam-bot` には `base` / `overlays/prod` / `argocd` を含む。 |
| **terraform/** | `aws/terraform/`・`oci/`（`minecraft/` を含む）・`test/` などの Terraform 定義。`gcp/` はディレクトリのみの場合があります。 |
| **cloudflare/** | Cloudflare 関連の設定用（現状はプレースホルダ）。 |

## 前提条件・注意

- **EC2 スクリプト**: AWS CLI のインストールと `aws configure` による認証設定
- **Terraform**: 各環境ディレクトリ（例: `terraform/aws/terraform/`, `terraform/oci/`）で `terraform init` を実行し、必要変数を設定すること
- **Ansible**: 対象ホストへの SSH 接続と、`ansible/README.md` に記載の前提条件（鍵・ユーザーなど）を満たすこと

必要に応じて、各サブディレクトリの README や `variables.tf` を確認してから実行してください。
