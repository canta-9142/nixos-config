# Nix Remote Builder（Phase 2）

ノートPCのビルドを原則Ryzenへ委譲する。接続先はMesh上の`ryzen.home.arpa`（`100.96.0.1`）。
flake評価・成果物取得・ノートPCへの適用はノートPC側で行う。

## 普段の操作

ノートPC上で実行する。`NH_FLAKE`は`~/nixos-config#nixos`に設定済み。

```sh
# ノートPCを更新（ビルドは原則Ryzen）
nh os switch

# flake inputsも更新する
nh os switch --update

# Ryzenが使えない場合はローカルでビルドして更新する
nh os switch --builders '' --max-jobs 1
```

`nixos-rebuild`でも同じオプションを使える。

```sh
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
sudo nixos-rebuild switch --flake ~/nixos-config#nixos --builders '' --max-jobs 1
```

自動でローカル実行へは切り替えない。途中切断で失敗した場合も、上記のローカル指定で再実行する。
途中状態の引き継ぎは保証しない。Ryzen復旧後は上書き指定を外すだけでよい。
通常の`nix build`にも同じ`--builders '' --max-jobs 1`を追加できる。

### Ryzen自体の更新

ノートPC上の`~/servers-config`からdeploy-rsで更新する。
`flake.nix`の`deploy.nodes.ryzen`で接続先とビルド方法を定義している。
管理ユーザー`jinji`でMesh経由で接続し、Ryzen自身でビルドしてから、
sudoパスワードを使ってrootとして適用する。

```sh
cd ~/servers-config
nix develop -c deploy .#ryzen
```

`autoRollback`と`magicRollback`は既定の有効状態を使う。
適用失敗時、または適用後のSSH経由の確認ができない場合は旧構成へ戻す。
アプリのヘルスチェックや、再起動後の起動確認を代替するものではない。
sudoパスワードはローカルで入力し、適用に使う。CIからのOS自動更新は行わない。
ビルド専用の`nix-builder`アカウントは適用には使わない。

初回適用前の検証（実機への設定適用は行わない）:

```sh
nix flake check --no-build
nix build --no-link .#checks.x86_64-linux.deploy-schema \
  .#checks.x86_64-linux.deploy-activate \
  .#checks.x86_64-linux.deploy-rollback
```

`deploy-schema`は定義の形式、`deploy-activate`はactivationスクリプトの存在を検証する。
`deploy-rollback`は使い捨てVMの専用profileで確認応答のタイムアウトと適用失敗を起こし、
旧profileへの切り戻しと再適用を確認する。実機のSSH・Mesh接続は別途確認する。
ROCK 3B・Cubie A5Eはdeploy-rsの対象に追加していない。

初回適用時の旧世代は`nixos-rebuild`由来のため、deploy-rsのactivationスクリプトを持たない。
その世代へ戻す際は自動再適用が失敗する可能性がある。初回は現行のstore pathを控え、
コンソール等からその世代の`bin/switch-to-configuration switch`を実行できる状態で行う。

従来の`nixos-rebuild`も利用できる。

```sh
nixos-rebuild switch --flake ~/servers-config#ryzen \
  --build-host jinji@ryzen.home.arpa \
  --target-host jinji@ryzen.home.arpa \
  --ask-sudo-password
```

普段のコマンドはfishの`abbr`に登録すればよく、専用スクリプトは不要。

## 設定の場所

| 対象 | ファイル |
| --- | --- |
| Ryzenの専用ユーザー・ビルド設定 | `modules/system/nix-builder.nix` |
| ビルド用SSH公開鍵 | `hosts/ryzen/nix-builder.pub` |
| ノートPCの委譲先・SSH設定 | `~/nixos-config/hosts/laptop/nix-builder.nix` |
| 暗号化したSSH秘密鍵 | `~/nixos-config/secrets/nix-builder.yaml` |

秘密鍵はsops-nixで`/run/secrets/nix_builder_private_key`へ配備する（root所有、0400）。
専用ユーザー`nix-builder`の鍵は`nix-daemon --stdio`のみ実行でき、PTY・ポート転送は許可しない。
ただしNixのtrusted userであり、信頼できない利用者向けの隔離には使わない。
SSHホスト公開鍵はクライアント設定に固定する。接続先やホスト鍵の変更時はその設定も更新する。

### 並列度の調整

- ノートPCの`nix.settings.max-jobs = 0`：通常のローカルビルドを無効化する。
- ノートPCの`nix.buildMachines`の`maxJobs`：Ryzenへ同時に委譲するビルド数。
- Ryzenの`nix.settings.max-jobs`：Ryzen側の同時ビルド数。
- Ryzenの`nix.settings.cores`：各ビルド内の並列度。物理コアの割り当てやメモリ上限ではない。

同時ビルド数を増やす際は、両側の設定を確認する。サーバーだけを`auto`にしても、クライアントの`maxJobs = 1`では委譲は同時1件まで。
`preferLocalBuild`が指定された処理はローカル実行されるため、switchの全処理がRyzenへ移るわけではない。

## 動作確認

ノートPCで専用鍵による接続を確認する。専用鍵で通常のシェルにはログインしない。

```sh
sudo nix store info --store 'ssh-ng://nix-builder@ryzen.home.arpa?ssh-key=/run/secrets/nix_builder_private_key'
```

`~/servers-config`で、キャッシュ取得だけでは終了しない小規模ビルドを実行する。

```sh
nix build --impure --no-link --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; };
  in pkgs.runCommand "phase2-probe-${toString builtins.currentTime}" {
    preferLocalBuild = false;
    allowSubstitutes = false;
  } "echo ok > $out"
'
```

ログの`building ... on 'ssh-ng://nix-builder@ryzen.home.arpa'`を確認する。
`nh os build`では設定を適用せず、NixOS構成のビルドを確認できる。

## 確認済みの範囲（2026-09-28）

Phase 2は日常利用可能な状態。性能調整は運用改善として扱う。

- **実機**：両ホストへ適用済み。専用鍵・ホスト鍵検証付きの接続、リモートビルド、クライアントへの成果物取得を確認。`nh os switch --update`での利用と、手動指定によるローカルビルドの成功も確認済み。
- **VM**：`nix flake check`でリモートビルド、接続不能時の失敗、手動ローカル実行、復旧後の再委譲を確認。実運用の秘密鍵は使用しない。
- **未実施**：実機で意図的に接続不能・途中切断を起こす障害試験、大規模ビルドのメモリ計測。
