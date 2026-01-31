# Ansible Playbooks for kind 学習環境

kind (Kubernetes in Docker) の学習用環境を構築するための Ansible playbook 集です。

## 概要

このリポジトリには、Linux サーバー上に kind クラスタを構築するための Ansible playbook が含まれています。
初期セットアップから kind クラスタの作成まで、段階的に環境を構築できます。

## 前提条件

- Ansible がインストールされていること
- 対象サーバーへの SSH 接続が可能であること
- 対象サーバーで sudo 権限を持つユーザーで接続できること
- 公開鍵 `~/.ssh/oci_terraform_key.pub` が存在すること

## ファイル構成

```
.
├── README.md                    # このファイル
├── ansible.cfg                  # Ansible 設定ファイル
├── inventory                     # インベントリファイル（対象ホストの定義）
├── linux-setup.yml              # ユーザー作成とSSHキー設定用 playbook
├── setup-kind.yml               # Docker と kind セットアップ用 playbook
└── roles/                       # 再利用可能なロール
    ├── docker/                  # Docker インストール用ロール
    └── user_k8s/                # k8s ユーザー作成用ロール
```

## セットアップ手順

以下の順序で playbook を実行してください。

### 1. ユーザー作成とSSHキー設定 (`linux-setup.yml`)

ansible ユーザーと k8s ユーザーを作成し、SSH 公開鍵を設定します。

```bash
ansible-playbook -i inventory linux-setup.yml \
  --private-key ~/.ssh/oci_terraform_key \
  -u <初期ユーザー名>
```

**実行内容:**
- `ansible` ユーザーの作成（sudo グループに追加）
- `ansible` ユーザーへの SSH 公開鍵設定
- `ansible` ユーザーのパスワードレス sudo 設定
- `k8s` ユーザーの作成
- `k8s` ユーザーへの SSH 公開鍵設定

**注意:** `public_key_path` 変数（デフォルト: `~/.ssh/oci_terraform_key.pub`）を変更する場合は、`-e` オプションで指定してください。

### 2. kind セットアップ (`setup-kind.yml`)

Docker と kind、kubectl をインストールし、kind クラスタを作成します。

```bash
ansible-playbook -i inventory setup-kind.yml \
  --private-key ~/.ssh/oci_terraform_key \
  -u ansible
```

**実行内容:**
- Docker のインストールと起動
- `k8s` ユーザーを docker グループに追加
- kind バイナリのダウンロード（デフォルト: v0.26.0）
- kubectl バイナリのダウンロード（デフォルト: v1.32.0）
- kind クラスタ設定ファイルの作成
- kind クラスタの作成（`my-cluster`）

**変数のカスタマイズ:**
- `kind_version`: kind のバージョン（デフォルト: `v0.26.0`）
- `kubectl_version`: kubectl のバージョン（デフォルト: `v1.32.0`）
- `arch`: アーキテクチャ（デフォルト: `arm64`、AMD64 の場合は `amd64` に変更）

例:
```bash
ansible-playbook -i inventory setup-kind.yml \
  --private-key ~/.ssh/oci_terraform_key \
  -u ansible \
  -e arch=amd64
```

## 各 Playbook の詳細

### `linux-setup.yml`

初期セットアップ時に実行する playbook です。以下のユーザーを作成し、SSH 公開鍵を設定します：

- **ansible ユーザー**
  - sudo グループに所属
  - パスワードレス sudo が有効
  - SSH 公開鍵が設定済み

- **k8s ユーザー**
  - kind クラスタの操作に使用
  - SSH 公開鍵が設定済み
  - 後続の playbook で docker グループに追加される

### `setup-kind.yml`

kind クラスタ構築のための環境を整えます：

1. Docker のインストールと起動
2. `k8s` ユーザーを docker グループに追加
3. kind と kubectl のバイナリをダウンロード
4. kind クラスタ設定ファイルの作成（control-plane 1 ノード、worker 1 ノード）
5. kind クラスタ `my-cluster` の作成

クラスタ作成後、`k8s` ユーザーでログインし、以下のコマンドで kubectl を使用できます：

```bash
kubectl get nodes
kubectl cluster-info
```

## インベントリファイル

`inventory` ファイルには対象ホストが定義されています：

```ini
[linux]
217.142.224.159
```

特定のホストに対してのみ実行する場合は、`-l` オプションを使用します：

```bash
ansible-playbook -i inventory setup-kind.yml \
  --private-key ~/.ssh/oci_terraform_key \
  -u ansible \
  -l 217.142.224.159
```

## 注意事項

1. **実行順序**: playbook は指定された順序で実行してください。後続の playbook は前の playbook で作成されたユーザーや設定に依存しています。

2. **アーキテクチャ**: `setup-kind.yml` の `arch` 変数は、対象サーバーのアーキテクチャに合わせて変更してください（ARM の場合は `arm64`、AMD64 の場合は `amd64`）。

3. **SSH キー**: デフォルトでは `~/.ssh/oci_terraform_key.pub` が使用されます。異なるキーを使用する場合は、`linux-setup.yml` の `public_key_path` 変数を変更するか、`-e` オプションで指定してください。

4. **クラスタ名**: デフォルトのクラスタ名は `my-cluster` です。変更する場合は `setup-kind.yml` を編集してください。

5. **既存クラスタ**: `setup-kind.yml` は既にクラスタが存在する場合（`/home/k8s/.kube/config` が存在する場合）はスキップされます。

## トラブルシューティング

### kind クラスタの削除

既存のクラスタを削除して再作成する場合：

```bash
# k8s ユーザーでログイン
ssh -i ~/.ssh/oci_terraform_key k8s@<ホストIP>

# クラスタを削除
kind delete cluster --name my-cluster

# 設定ファイルを削除（必要に応じて）
rm -rf ~/.kube
```

その後、`setup-kind.yml` を再実行してください。

### Docker グループの確認

`k8s` ユーザーが docker グループに所属しているか確認：

```bash
groups k8s
```

所属していない場合は、`setup-kind.yml` の「Add k8s to docker group」タスクを再実行してください。
