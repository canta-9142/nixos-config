# servers-configのキャッシュ移行

Forgejoの正本は`ssh://git@ryzen.home.arpa:2222/jinji/servers-config.git`。
ローカルの`origin`をForgejoへ切り替え、GitHubは`github` remoteとして残す。
Cubie A5E設定と、キャッシュ・Runnerの準備をコミットしてpushする。

Ryzen側の作業コピーは、同じForgejoへ`http://127.0.0.1:3000/jinji/servers-config.git`で接続する。
Ryzen自身のMesh名の名前解決・Forgejo向けSSH認証には依存せず、ローカルHTTPで取得する。
GitHubの接続先はRyzen側でも`github` remoteに残している。

## 追加した基盤

- Ryzenのaarch64 binfmtは実機で有効化済み。
- 既存の`cache.floating-gate.com`、署名鍵、公開コマンドを共有する。
- `nix-cache-publish --group servers-config STORE_PATH...`でサーバー用成果物をまとめて記録する。
  groupを省略する既存呼び出しと、groupのない既存履歴は`nixos-config`として扱う。
- GCは直近14日分と、リポジトリごとの最新成功分を全依存物とともに保持する。
- `nix-cache-update`は`CACHE_UPDATE_REPOSITORY`、`CACHE_UPDATE_PUBLIC_KEY_FILE`、
  引数のbuild対象を受け取る。省略時は従来のlaptop用動作を維持する。
- `servers-nix-cache-update`はサーバー3台のtoplevelとNVMeイメージ2種をまとめて更新・公開・検証する。
  CI用の使い捨てcheckoutで実行するコマンドであり、普段の作業コピーでは実行しない。
- Runnerは`forgejo-runner-servers.service`、ラベルは`ryzen-servers-build`。
  登録・作業ディレクトリは`/var/lib/gitea-runner-servers`。
  既存の非trustedユーザー`nix-ci`と、署名公開コマンドだけのsudo権限を使う。

手順5では手動workflow、手順6では各ホストのキャッシュ利用設定を追加する。
定期lock更新は手順7の設定で実行する。通常のビルドは手動で実行する。
`nixos-config`側の既存CIを停止・再登録する必要はない。

## 手動1: ForgejoのActionsとRunner登録トークン

1. `https://git.floating-gate.com/jinji/servers-config`のSettingsでActionsを有効にする。
2. 同リポジトリのSettings → Actions → Runnersから登録トークンを取得する。
3. 次の操作を手元の端末で実行し、Ryzenのsudoパスワードを入力する。

```sh
ssh -t jinji@ryzen.home.arpa
sudo install -d -m 0700 /etc/forgejo-runner
sudo test ! -e /etc/forgejo-runner/servers-nix.env && sudo install -m 0600 /dev/null /etc/forgejo-runner/servers-nix.env
sudoedit /etc/forgejo-runner/servers-nix.env
```

エディタ内で`TOKEN=取得した登録トークン`の1行を保存する。
トークンはチャット・Git・コマンド履歴へ記載しない。既存の`nix.env`は変更しない。
既に`servers-nix.env`がある場合、上記コマンドは空ファイルで上書きしない。
完了後、`exit`でPC側へ戻る。

## 手動2: Ryzenへの適用

更新後の作業コピーがcleanであることと、originがForgejoであることを確認する。
Ryzenで未コミットだったnixpkgs revisionは今回のlockに取り込み、元の変更は
`/home/jinji/servers-config-lock-before-cache-migration.51QjI4`へバックアップ済み。
PC・Ryzenの作業コピーはともにForgejoのmainへ同期済み。

PC側で実行する。

```sh
cd ~/servers-config
nixos-rebuild switch --flake .#ryzen \
  --build-host jinji@ryzen.home.arpa \
  --target-host jinji@ryzen.home.arpa \
  --ask-sudo-password
```

長いビルドやキャッシュ公開が動いている場合は、それらが終了してから適用する。
適用時にはRyzenのsudoパスワードが必要。トークン未配置の場合、Runnerは起動を見送る。
後からトークンを配置した場合は`sudo systemctl start forgejo-runner-servers`で起動する。

## 手動3: 起動確認

RyzenへSSH接続して確認する。

```sh
systemctl status forgejo-runner-servers --no-pager
journalctl -u forgejo-runner-servers -n 50 --no-pager
cat /proc/sys/fs/binfmt_misc/aarch64-linux
test -x /run/current-system/sw/bin/servers-nix-cache-update
sudo nix-cache-gc --dry-run
```

ForgejoでRunnerがonline、ラベルが`ryzen-servers-build`であることを確認する。
GCはこの時点ではdry-runだけにし、既存laptopキャッシュの履歴を含む保持対象を確認する。
既存の`forgejo-runner-nix`も起動していることを確認する。

## 手順5: CIでビルド・公開する

`.forgejo/workflows/nix-cache.yml`の`Build and publish server configurations`を使用する。
`main`へのpushで自動実行する。ForgejoのActionsでこのworkflowを開き、
`Run workflow`から`main`を指定して手動実行することもできる。
通常のpush・手動実行はlockを更新せず、checkoutしたコミットをビルドする。

1. Ryzen・ROCK 3B・Cubie A5Eのtoplevelと、NVMeイメージ2種をビルドする。
2. 5つの成果物を`--group servers-config`でまとめて署名・公開する。
3. 公開HTTPSで、全closureのメタデータ・署名を検証する。

build stepのログに成果物のstore pathを出力する。
全stepの成功を確認するまで、そのコミットをキャッシュ公開済みとは扱わない。
Cubie A5Eのカーネルはx86_64からaarch64へクロスコンパイルし、コンパイル時のQEMUを回避する。
その他のaarch64ビルドには引き続きbinfmtを使用する。初回のカーネルビルドは長時間かかる場合がある。
workflowとRunnerの制限は8時間。同じworkflowの実行は直列化する。
既存のlaptop CIとはRunnerが別なので、初回は他の重いビルドがない時間に実行する。

## 手順6: 各ホストでキャッシュを利用する

`modules/system/common.nix`から`nix-cache.nix`を読み込み、3台とも次を設定する。

- 取得先: `https://cache.floating-gate.com?priority=50`
- 信頼鍵: Ryzenから管理SSHで取得済みの`modules/system/nix/cache.pub`
- `always-allow-substitutes = true`（fish補完なども取得する）
- `fallback = true`（取得失敗時は利用可能なビルダーでビルドする）

標準の`cache.nixos.org`も引き続き利用する。
ノートPCは既に同じキャッシュの利用設定が適用済みなので、CI成功後は
同じコミットの`nix build .#cubiea5e-image`などで生成物を取得できる。

CI成功後、RyzenにはPCから次を適用する。sudo認証が必要。

```sh
cd ~/servers-config
nixos-rebuild switch --flake .#ryzen \
  --build-host jinji@ryzen.home.arpa \
  --target-host jinji@ryzen.home.arpa \
  --ask-sudo-password
```

Ryzen側で`nix config show`を確認し、取得先・信頼鍵・上記2つの設定が有効であることを確認する。
ROCK 3BとCubie A5Eはまだ停止中のため、実機での取得確認は起動後に行う。
今回の設定から生成するNVMeイメージには、初回起動時からキャッシュ設定を含める。
既存インストールへ反映する場合は、それぞれのホスト上で
`sudo nixos-rebuild switch --flake /home/jinji/servers-config#rock3b`、
`sudo nixos-rebuild switch --flake /home/jinji/servers-config#cubiea5e`を実行する。

キャッシュ欠損時のビルド委譲とキャッシュ利用は別設定である。
ノートPCからaarch64のビルドもRyzenへ委譲する場合は、`nixos-config`側のbuilder宣言にも
`aarch64-linux`を追加する。これはキャッシュ取得だけなら不要。

## 手順7: 毎朝6時のlock更新

`nix-cache.yml`の`update-lock`ジョブを毎日06:00（日本時間）に実行する。
Forgejoのcronは既定でUTCのため、指定は`0 21 * * *`。
同じworkflowのpush・手動ビルドとは直列化し、最大8時間、`--max-jobs 1 --cores 14`で動作する。

1. 最新のmainを取得し、`nix flake update`でflakeの全inputを更新する。
2. サーバー3台のtoplevelとNVMeイメージ2種をビルドする。
3. キャッシュへ署名・公開し、公開HTTPS経由でclosureのメタデータと署名を検証する。
4. 成功した場合だけ`flake.lock`のコミットをmainへpushし、コミットの成功ステータスを登録する。

更新差分がない場合もビルド・公開・検証を行い、コミットは作成しない。
競合した場合は最新mainからやり直す。更新・ビルド・公開・検証の失敗時はlock更新をpushしない。
workflowの`Run workflow`で`update_lock`を有効にすると、同じ処理を手動実行できる。
更新コミットには`[skip ci]`を付け、すでにビルド・公開した更新から通常CIが重複起動するのを避ける。

更新処理はcheckoutした`scripts/update-nix-cache.sh`を使用し、必要なツールは
ロック済みnixpkgsから`nix shell`で取得する。スケジュールの追加にRyzenの再適用は不要。
