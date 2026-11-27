# servers-config

Ryzen主系サーバー、ROCK 3B、Cubie A5EのNixOS構成。

- [要件・ロードマップ](servers-roadmap.md)
- [ROCK 3B基本構成の移行](rock3b-migration.md)
- [Cubie A5EのNVMe構成・起動準備](cubiea5e.md)
- [Ryzen SSD・RAID復旧手順](ryzen-storage-recovery.md)
- [Immichの導入・Mesh接続・バックアップ手順](immich.md)
- [Nix Remote Builderの適用・運用手順](nix-remote-builder.md)
- [Nix Binary Cache・12時間ごとの更新計画](nix-binary-cache.md)
- [servers-configのForgejo・キャッシュ移行とRunner準備](servers-cache-migration.md)
- [Forgejoの移行・公開手順](forgejo-migration.md)
- [Actions Runnerの登録・Web CI確認手順](forgejo-runner.md)
- [Ryzen Webデプロイ・公開切替手順](web-deployment.md)

Phase 4のForgejo移行は2026-09-29に実用上完了。ROCK本体停止試験は未実施、
ROCK実機への適用は保留。基本構成のみ本リポジトリへ移植済み。
Phase 5はRyzen RunnerでWebビルドとCI失敗時の本番維持を確認済み。
Phase 6は2026-09-29に完了。DNS切替後の公開アクセス、実機でのビルド失敗時の
release維持、復旧後の正常デプロイと公開`/healthz`を確認済み。
Phase 7はBinary Cache基盤の公開・署名付きprobe取得、laptop設定適用、Forgejoへの正本移行を確認済み。
専用Nix Runnerの初回CI成功とlaptopでのキャッシュ利用を利用者が確認済み。
2026-10-06 09:00 JSTの初回定期実行は成功。fish補完を含むキャッシュ利用の恒久設定・適用も確認済み。
キャッシュのretentionは直近14日分と最新公開成功分を保持する方式を実装済み（実機適用は未確認）。
成功statusの公開ログリンク修正が残る。

```text
flake.nix
hosts/ryzen/           ホスト設定・ディスク・ハードウェア
hosts/rock3b/          ROCK 3Bの起動・ハードウェア・bond・管理SSH
hosts/cubiea5e/        Cubie A5EのNVMe起動・ハードウェア・管理SSH
lib/                  extlinuxを使うNVMeイメージの生成
assets/edid/          ROCK 3BのHDMI用EDID
modules/system/       SSH・Mesh・保守・管理ユーザー
tests/deploy.nix        deploy-rsの確認タイムアウト・適用失敗時の切り戻し試験
tests/forgejo.nix       Forgejo移行・起動抑止・Mesh SSH制限の試験
tests/web.nix           nginx・healthz・公開release切替の試験
tests/nix-cache.nix     署名付きcache・closure取得・障害時buildの試験
tests/nix-cache-gc.py   キャッシュの14日保持・依存物保護・異常時削除抑止の試験
tests/nix-cache-update.py 定期更新のpush抑止・Git競合の回帰試験
```

`nixpkgs`は既存の`~/nixos-config`と同じrevisionから開始し、`flake.lock`で固定。
ROCK 3Bは基本構成のみ移植し、既存のサーバー機能は引き継がない。
実機への適用は別途行う。移行元の`~/nixos-config`は変更していない。

## 開発・検証

```sh
nix develop
nix fmt
statix check .
deadnix --fail .
nix flake check
nix build .#nixosConfigurations.ryzen.config.system.build.toplevel
nix build .#rock3b-image --out-link result-rock3b-image
nix build .#cubiea5e-image --out-link result-cubiea5e-image
```

ROCKのNVMe用イメージは`result-rock3b-image/rock3b-nvme.img`に生成する。
設定済みのU-Bootを利用する。詳細は[移行メモ](rock3b-migration.md#nvme用イメージ)を参照。

`nix flake check`は使い捨てVMでForgejoの移行前の起動抑止、データ・鍵の引き継ぎ、
新しいclone URL、定期dump、Mesh経由だけのGit SSH接続を確認する。
Web公開releaseの切替と、Binary Cacheの署名付きclosure取得・別鍵での拒否・障害時ビルドも確認する。
Cubie A5Eではカーネルパッチの適用とDevice Tree・SPI NOR overlayのコンパイル・結合も確認する。
x86_64 LinuxとKVMが必要。実機のディスクにはアクセスしない。
新しいファイルを追加した場合は、flakeから参照できるようGitに追加する。
ビルド・検証コマンドは現在のホストへ設定を適用しない。

## Ryzenへの適用

```sh
nix develop -c deploy .#ryzen
```

Mesh上の`ryzen.home.arpa`へ`jinji`で接続し、Ryzen自身でビルドしてsudoで適用する。
接続先のsudoパスワードを入力する。適用失敗・確認応答のタイムアウト時は旧構成へ戻す。
対象はRyzenのみ。初回の検証や従来の適用方法は[運用手順](nix-remote-builder.md#ryzen自体の更新)を参照。
