# infra

インフラストラクチャの定義・運用スクリプトをまとめたリポジトリです。  
Ansible / Kubernetes / Terraform / 補助スクリプトを中心に、クラウド・学習環境の構築と運用に利用します。

## 概要

- **Ansible**: Linux 初期設定（`setup-linux.yml`）、kind / k3s、CLI ツール（roles 経由）、Argo CD / Helm / Prometheus のセットアップ
- **Kubernetes**: `steam-bot` / `dummy` / `test` / `training` 用マニフェスト（`test` は Kustomize と Argo CD Application を含む）
- **Terraform**: AWS / GCP / OCI（`minecraft/` を含む）/ Cloudflare / `test/` などの IaC 定義
- **Script**: AWS CLI を使った EC2 起動・停止・情報取得スクリプト

## ディレクトリ構成

```
infra/
├── README.md           # このファイル
├── ansible/            # Ansible playbooks（kind / ArgoCD / Helm / Prometheus 等）
├── kubernetes/         # Kubernetes マニフェスト（steam-bot / dummy / test / training / argo-workflows）
├── script/             # EC2 操作用スクリプト
└── terraform/          # Terraform 定義
    ├── aws/            # AWS
    ├── cloudflare/     # Cloudflare（DNS・プロバイダーなど）
    ├── gcp/            # GCP（現状プレースホルダのみの場合があります）
    ├── oci/            # Oracle Cloud（minecraft/ など）
    └── test/           # Terraform 検証・学習用
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

**注意:** 各スクリプトは `aws` コマンドを利用するため、事前に `aws configure` などで認証情報を設定してください。実行時は、この `README.md` と同じ階層（リポジトリのルート）をカレントディレクトリにしてください。

## 各ディレクトリの説明

| ディレクトリ | 説明 |
|-------------|------|
| **script/** | AWS CLI を用いた EC2 操作用スクリプト（起動・停止・一覧取得）。 |
| **ansible/** | kind/K3s 学習環境の構築、ArgoCD / Helm / Prometheus のインストール、Linux セットアップ。詳細は [ansible/README.md](ansible/README.md) を参照。 |
| **kubernetes/** | `steam-bot` / `dummy` / `test` / `training` のマニフェスト。`steam-bot` には `base` / `overlays/prod` / `argocd`、`test` には Deployment・Kustomize・Argo CD Application を含む。 |
| **kubernetes/cert-manager/** | cert-manager + Cloudflare DNS-01によるLet's Encrypt証明書発行のセットアップ（ClusterIssuer等）。詳細は [kubernetes/cert-manager/README.md](kubernetes/cert-manager/README.md)。 |
| **kubernetes/argocd/** | ArgoCDをIngress + SSO(Dex/Google OAuth)でブラウザログインできるようにする設定。詳細は [kubernetes/argocd/README.md](kubernetes/argocd/README.md)。 |
| **kubernetes/argo-workflows/** | Argo WorkflowsをブラウザでSSOログイン（推奨）、またはClient認証(ServiceAccountトークン)で閲覧するための設定。手順は [kubernetes/argo-workflows/README.md](kubernetes/argo-workflows/README.md)。 |
| **terraform/aws/** | AWS 用 Terraform。ディレクトリ内で `terraform init` を実行します。`.terraform.lock.hcl` はリポジトリに含まれます。 |
| **terraform/cloudflare/** | Cloudflare（DNS・provider など）。認証情報はリポジトリに含めず、ローカルに `secret.tfvars` を置き `-var-file=secret.tfvars` などで渡す運用が想定されます（ファイルは `.gitignore` で除外）。 |
| **terraform/gcp/** | GCP 用（現状ファイルが無い場合は `.gitkeep` のみなど）。 |
| **terraform/oci/** | Oracle Cloud 用 Terraform（`minecraft/` サブディレクトリを含むことがあります）。 |
| **terraform/test/** | Terraform の検証・学習用スタック。 |

## 前提条件・注意

- **EC2 スクリプト**: AWS CLI のインストールと `aws configure` による認証設定
- **Terraform**: 各スタックのディレクトリ（例: `terraform/aws/`、`terraform/oci/`、`terraform/cloudflare/`）で `terraform init` を実行し、必要な変数ファイルや環境変数を用意すること
- **Ansible**: 対象ホストへの SSH 接続と、[ansible/README.md](ansible/README.md) に記載の前提条件（鍵・ユーザーなど）を満たすこと

必要に応じて、各サブディレクトリの README や `variables.tf` を確認してから実行してください。
