# infra

インフラストラクチャの定義・運用スクリプトをまとめたリポジトリです。  
AWS / OCI / Kubernetes / Ansible / Terraform など、各種クラウド・オンプレ環境の構築・管理に利用します。

## 概要

- **AWS EC2**: インスタンスの起動・停止や Terraform による自動作成
- **OCI (Oracle Cloud)**: Terraform によるリソース管理（Minecraft 用含む）
- **Kubernetes**: dev / prod / test / training 環境のマニフェスト
- **Ansible**: kind 学習環境や ArgoCD / Helm / Prometheus のセットアップ
- **Terraform**: 汎用・テスト用の定義
- **Cloudflare**: 設定用ディレクトリ（予備）

## ディレクトリ構成

```
infra/
├── README.md           # このファイル
├── get_ec2_id.sh       # EC2 インスタンスID・パブリックIPの一覧取得
├── start_ec2.sh        # EC2 インスタンスの起動
├── stop_ec2.sh         # EC2 インスタンスの停止
├── ansible/            # Ansible playbooks（kind / ArgoCD / Helm / Prometheus 等）
├── aws/                # AWS 用 Terraform（EC2 自動作成など）
├── cloudflare/         # Cloudflare 関連
├── kubernetes/         # Kubernetes マニフェスト（dev / prod / test / training）
├── oci/                # OCI 用 Terraform（Minecraft 含む）
└── terraform/          # 汎用・テスト用 Terraform
```

## EC2 スクリプト（AWS CLI）

AWS CLI が設定済みであることを前提に、EC2 の操作を行います。

### インスタンス一覧の取得

```bash
./get_ec2_id.sh
```

- 全 EC2 の **InstanceId** と **PublicIpAddress** をテキストで出力します。

### インスタンスの起動

```bash
./start_ec2.sh <インスタンスID> [インスタンスID ...]
```

例:

```bash
./start_ec2.sh i-05f688f88e7906c22
```

### インスタンスの停止

```bash
./stop_ec2.sh <インスタンスID> [インスタンスID ...]
```

例:

```bash
./stop_ec2.sh i-05f688f88e7906c22
```

**注意:** 各スクリプトは `aws` コマンドを利用するため、事前に `aws configure` などで認証情報を設定してください。

## 各ディレクトリの説明

| ディレクトリ | 説明 |
|-------------|------|
| **ansible/** | kind 学習環境の構築、ArgoCD / Helm / Prometheus のインストール、Docker・K8s ユーザー設定、iptables / kind セットアップなど。詳細は [ansible/README.md](ansible/README.md) を参照。 |
| **aws/** | Terraform による EC2 の自動作成（AMI・インスタンスタイプ・セキュリティグループ等を変数で指定）。 |
| **kubernetes/** | 環境別（dev / prod / test / training）の Deployment / Service / Ingress / Namespace などのマニフェスト。training は章ごとのサンプルあり。 |
| **oci/** | OCI 用 Terraform（Minecraft 用の定義は `oci/minecraft/`）。 |
| **terraform/** | 汎用・テスト用の Terraform 定義。 |
| **cloudflare/** | Cloudflare 関連の設定用（現状はプレースホルダ）。 |

## 前提条件・注意

- **EC2 スクリプト**: AWS CLI のインストールと `aws configure` による認証設定
- **Terraform**: 各 `*.tf` があるディレクトリで `terraform init` の実行と、必要な変数（`variables.tf` 等）の設定
- **Ansible**: 対象ホストへの SSH 接続と、ansible 用 README に記載の前提条件（鍵・ユーザーなど）を満たすこと

必要に応じて、各サブディレクトリの README や `variables.tf` を確認してから実行してください。
