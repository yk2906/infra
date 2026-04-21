# Ansible Playbooks for Kubernetes 学習環境

kind（Kubernetes in Docker）を中心とした Kubernetes 学習用の Ansible playbook 集です。k3s の導入、Helm 経由のアプリ導入、CLI ツールのインストール用 playbook も同梱しています。

## 概要

Linux サーバー上に kind クラスタを構築する流れ（ユーザー作成 → Docker/kind/kubectl → クラスタ作成）を想定した手順がメインです。別途、k3s・iptables 開放・Helm / Argo CD / Prometheus など、環境や目的に応じて使い分けられる playbook があります。

## 前提条件

- Ansible がインストールされていること
- リモート向け playbook では、対象サーバーへの SSH 接続と、sudo 可能なユーザーが使えること
- `setup-linux.yml` のデフォルトでは、制御ノードに公開鍵 `~/.ssh/oci_terraform_key.pub` が存在すること
- **Helm / Argo CD / Prometheus 用**（`install-helm.yml`、`install-argocd.yml`、`install-prometheus.yml`）: 対象クラスタが起動済みで、`k8s` ユーザーに有効な kubeconfig があること。さらに Ansible コレクション `kubernetes.core` が必要です（未導入の場合は `ansible-galaxy collection install kubernetes.core`）。

## ファイル構成

```
.
├── README.md
├── ansible.cfg                  # inventory パスなど
├── inventory                    # ホスト定義
├── setup-linux.yml              # ansible / k8s ユーザーと SSH 鍵
├── setup-kind.yml               # Docker（docker.io）+ kind + kubectl + クラスタ作成
├── install-k3s.yml              # k3s（server / agent）
├── setup-k3s-environment.yml    # k3s + ローカル CLI（k9s / kubectx / kubens）まとめて
├── setup-iptables.yml           # iptables をフラッシュしポリシー ACCEPT（学習用・注意）
├── install-helm.yml             # Helm 導入 + 例として bitnami/nginx
├── install-argocd.yml           # Helm で Argo CD
├── install-prometheus.yml       # Helm で kube-prometheus-stack
├── install-k9s.yml              # 制御マシン（localhost）に k9s
├── install-kubectx.yml          # kubectx（connection: local）
├── install-kubens.yml           # kubens（connection: local）
└── roles/
    ├── docker/
    ├── k3s/
    ├── k9s/
    ├── kubectx/
    ├── kubens/
    └── user_k8s/
```

`setup-kind.yml` はロールではなくプレイ内タスクで Docker（`docker.io` パッケージ）を入れます。`roles/docker`（Docker CE リポジトリ）とは手順が異なります。

## セットアップ手順（kind）

以下の順序で playbook を実行してください。

### 1. ユーザー作成と SSH 鍵（`setup-linux.yml`）

`ansible` ユーザーと `k8s` ユーザーを作成し、SSH 公開鍵を設定します。

```bash
ansible-playbook -i inventory setup-linux.yml \
  --private-key ~/.ssh/oci_terraform_key \
  -u <初期ユーザー名>
```

**実行内容:**

- `ansible` ユーザーの作成（`sudo` グループ）、公開鍵、パスワードレス sudo
- `k8s` ユーザーの作成と公開鍵
- 共通パッケージ（`vim`、`net-tools`、`curl`、`bash-completion` など）の導入

**注意:** 公開鍵パスを変える場合は `-e 'public_key_path=~/.ssh/別の鍵.pub'` のように指定してください。

### 2. kind セットアップ（`setup-kind.yml`）

Docker と kind、kubectl を入れ、`my-cluster` を作成します。

```bash
ansible-playbook -i inventory setup-kind.yml \
  --private-key ~/.ssh/oci_terraform_key \
  -u ansible
```

**実行内容:**

- `docker.io` のインストールと起動
- `k8s` ユーザーを `docker` グループに追加
- kind（デフォルト: `v0.26.0`）、kubectl（デフォルト: `v1.32.0`）
- kind クラスタ設定の配置と `my-cluster` の作成

**変数のカスタマイズ:**

- `kind_version`（デフォルト: `v0.26.0`）
- `kubectl_version`（デフォルト: `v1.32.0`）
- `arch`（デフォルト: `arm64`。AMD64 なら `amd64`）

例:

```bash
ansible-playbook -i inventory setup-kind.yml \
  --private-key ~/.ssh/oci_terraform_key \
  -u ansible \
  -e arch=amd64
```

## その他の Playbook（概要）

| ファイル | 用途 | 備考 |
|-----------|------|------|
| `install-k3s.yml` | k3s server / agent のインストール | kind 等と API ポートが競合し得る。ファイル先頭のコメントに実行例と主要変数あり |
| `setup-iptables.yml` | フィルタ・NAT をフラッシュし、既定ポリシーを ACCEPT | **本番向けではない**（全開放） |
| `install-helm.yml` | Helm（デフォルト `v3.14.0`、`arch` 既定 `arm64`）+ 例: Bitnami Nginx | `kubernetes.core` が必要 |
| `install-argocd.yml` | `argo` Helm リポジトリ追加と `argo-cd` リリース | `k8s` ユーザーで実行 |
| `install-prometheus.yml` | `kube-prometheus-stack`（完了に数分〜10 分程度かかることがある） | 同上 |
| `install-k9s.yml` | k9s を **localhost** に導入 | `hosts: localhost`, `become: yes` |
| `install-kubectx.yml` / `install-kubens.yml` | kubectx / kubens を `connection: local` で配置 | インベントリにリモートホストが含まれるとホストごとにプレイが走るため、制御マシンだけに入れたい場合は `-l localhost` などで限定するとよい |
| `setup-k3s-environment.yml` | k3s（全ホスト）＋ 実行マシンに k9s / kubectx / kubens | `--tags k3s` で k3s のみ、`--tags k9s,kubectx_tools` で CLI のみ |

k3s の具体的なコマンド例は `install-k3s.yml` 先頭のコメントを参照してください。

## 各 Playbook の詳細（メイン手順）

### `setup-linux.yml`

初期接続用ユーザーから初回だけ実行する想定です。

- **ansible ユーザー**: `sudo`、パスワードレス sudo、SSH 公開鍵
- **k8s ユーザー**: SSH 公開鍵（Docker グループは `setup-kind.yml` で追加）

### `setup-kind.yml`

1. Docker（`docker.io`）のインストールと起動  
2. `k8s` を `docker` グループに追加  
3. kind / kubectl のバイナリ取得  
4. control-plane 1 + worker 1 の kind 設定ファイルを `/home/k8s/kind-config.yaml` に配置  
5. `kind create cluster --name my-cluster`

クラスタ作成後、`k8s` ユーザーで SSH し、次で確認できます。

```bash
kubectl get nodes
kubectl cluster-info
```

## インベントリファイル

`inventory` の一例（実ファイルに合わせて編集してください）:

```ini
[all]
localhost ansible_connection=local

[aws:children]
linux

[linux]
217.142.224.159
localhost

[windows]
```

リモートの IP は環境に合わせて差し替えてください。特定ホストだけに当てたい場合は `-l` を使います。

```bash
ansible-playbook -i inventory setup-kind.yml \
  --private-key ~/.ssh/oci_terraform_key \
  -u ansible \
  -l 217.142.224.159
```

## 注意事項

1. **実行順序**: kind 流儀では `setup-linux.yml` → `setup-kind.yml` の順が前提です。
2. **アーキテクチャ**: `setup-kind.yml` と `install-helm.yml` の `arch` は対象マシンに合わせてください。
3. **SSH 鍵**: `setup-linux.yml` の `public_key_path` は必要に応じて `-e` で上書きできます。
4. **クラスタ名**: kind のデフォルトは `my-cluster`。変える場合は `setup-kind.yml` を編集してください。
5. **既存クラスタ**: `setup-kind.yml` は `/home/k8s/.kube/config` が既にあるとクラスタ作成タスクをスキップします。
6. **kind と k3s**: 同一ホストでは API ポート（6443 など）が競合することがあります。`install-k3s.yml` のコメントも参照してください。

## トラブルシューティング

### kind クラスタの削除

```bash
ssh -i ~/.ssh/oci_terraform_key k8s@<ホストIP>
kind delete cluster --name my-cluster
rm -rf ~/.kube   # 必要なら
```

その後、`setup-kind.yml` を再実行してください。

### Docker グループの確認

```bash
groups k8s
```

`docker` が含まれない場合は、`setup-kind.yml` の「Add k8s to docker group」相当の状態を再適用してください。
