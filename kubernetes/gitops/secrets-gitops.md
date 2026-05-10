# GitOps で Secret を Git に載せる（SOPS + age / Sealed Secrets）

平文の Kubernetes `Secret` はコミットせず、**暗号化した状態で Git に置く**ための選択肢です。

| 方式 | クラウド課金 | 向いているケース | Argo CD |
|------|----------------|------------------|---------|
| **SOPS + age** | **不要**（ローカル鍵のみ） | 費用ゼロで Git に載せたい／複数レシピエント | Repo Server で復号（CMP・KSOPS 等）が必要 |
| **SOPS + GPG** | 不要 | 既に GPG で鍵交換しているチーム | 同上 |
| **Sealed Secrets** | 不要 | 「追加プラグインを増やしたくない」 | `SealedSecret` をそのまま同期しやすい |

---

## SOPS + age（クラウド KMS なし・無料）

クラウドの KMS は使わず **[Filippo Valsorda age](https://github.com/FiloSottile/age)** の鍵だけで暗号化します（公開鍵は Git に載せてよく、**秘密鍵だけ**は絶対にコミットしません）。

### 1. ツール

- [Mozilla SOPS](https://github.com/getsops/sops)
- `age`（多くの環境で `age-keygen` とセット）

### 2. 鍵の用意

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
# 標準エラーに公開鍵が表示される。または:
age-keygen -y ~/.config/sops/age/keys.txt
```

`keys.txt` は **`.gitignore` に相当する保管場所**（パスワードマネージャの添付など）で管理します。このリポジトリでは `*.agekey` 等を無視しています。

### 3. `.sops.yaml`（creation rules）

```bash
cp kubernetes/argo-workflows/.sops.yaml.example kubernetes/argo-workflows/.sops.yaml
# `REPLACE_WITH_YOUR_age1_PUBLIC_KEY` をあなたの `age1...` に置換
```

**`.sops.yaml` に書くのは公開鍵だけ**です。コミットして問題ありません。

### 4. 初回の暗号化ファイル作成（Git に載せる側）

```bash
cd kubernetes/argo-workflows

cp secret-slack-notion-sync-workflow.yaml secret-slack-notion-sync-workflow.local.yaml
# .local.yaml を編集して実トークン・ID を入れる（このファイルは gitignore）

cp secret-slack-notion-sync-workflow.local.yaml secret-slack-notion-sync-workflow.sops.yaml
sops --encrypt --in-place secret-slack-notion-sync-workflow.sops.yaml

git add .sops.yaml secret-slack-notion-sync-workflow.sops.yaml
git commit ...
```

以降の値変更は **`sops secret-slack-notion-sync-workflow.sops.yaml`** でエディタが開きます。

### 5. ローカルでの復号確認（任意）

```bash
sops --decrypt kubernetes/argo-workflows/secret-slack-notion-sync-workflow.sops.yaml
```

### 6. Argo CD での復号（概要）

Argo CD は標準状態では SOPS ファイルをそのままは適用できません。代表的なやり方は次のとおりです。

1. **Repo Server に age 秘密鍵を渡す**（Kubernetes の `Secret` でマウントするのが一般的。**この Secret は Git に載せない**）。
2. 環境変数 **`SOPS_AGE_KEY`**（鍵そのもの）または **`SOPS_AGE_KEY_FILE`**（ファイルパス）を Repo Server に設定する。
3. **復号してからマニフェストを生成する仕組み**を挟む。
   - [KSOPS](https://github.com/viaduct-ai/kustomize-sops)（Kustomize プラグイン）
   - [helm-secrets](https://github.com/jkroepke/helm-secrets)（Helm 利用時）
   - **Config Management Plugin（CMP）** で `sops decrypt` を実行するカスタム手段

公式・各プラグインの「Argo CD の repo-server への鍵の載せ方」を参照し、クラスタに合わせてください。

### 注意

- **バックアップ**: `keys.txt` を失うと復号不能です。オフラインの安全な場所にコピーを。
- **複数環境**: 環境ごとに別レシピエント（別 age 公開鍵）を `.sops.yaml` の `creation_rules` で分けると、`path_regex` だけで鍵を切り替えられます。
- **`encrypted_regex`**: `stringData` / `data` のみ暗号化する設定にしてあり、`metadata` の名前や namespace はプレーンのまま読めるようにしています。

---

## 方式: Sealed Secrets（Bitnami）

クラウド不要。コントローラがクラスタ内で復号します。

### 前提

- クラスタに [Sealed Secrets controller](https://github.com/bitnami-labs/sealed-secrets) が入っていること
- ローカルに `kubeseal` CLI があること

### 流れ

1. **平文 Secret はローカルだけ**（コミットしない）  
   `kubernetes/argo-workflows/secret-slack-notion-sync-workflow.local.yaml` のようにコピーして値を入れる。

2. **SealedSecret を生成してコミット**

```bash
kubeseal --format yaml \
  -f kubernetes/argo-workflows/secret-slack-notion-sync-workflow.local.yaml \
  -w kubernetes/argo-workflows/sealed-secret-slack-notion-sync-workflow.yaml
```

3. **Git に載せるのは `sealed-secret-*.yaml` のみ**  
   Argo CD が同期すると、コントローラが namespace `argo` に **`Secret` `argo-workflows-slack-notion`** を生成します。

### 注意

- **SealedSecret は作成時に namespace／クラスタ公開鍵にバインド**されます。別クラスタにはそのままでは流用できません。

---

## このリポジトリでのファイル役割（推奨）

| ファイル | 役割 |
|----------|------|
| `secret-slack-notion-sync-workflow.yaml` | キー構成のテンプレ（ダミー値のみ推奨） |
| `.sops.yaml`（`.example` から作成） | **age 公開鍵**と暗号化対象パターン（Git にコミット） |
| `secret-slack-notion-sync-workflow.sops.yaml` | **SOPS 暗号化済み Secret**（Git にコミット） |
| `secret-slack-notion-sync-workflow.local.yaml` | 実値の平文。**コミットしない** |
| `sealed-secret-slack-notion-sync-workflow.yaml` | Sealed Secrets 利用時のみ Git にコミット |

Webhook 用の `secret-notify-webhooks.example.yaml` も、同様に `.sops.yaml` の `path_regex` を追加して `*.sops.yaml` を増やせます。
