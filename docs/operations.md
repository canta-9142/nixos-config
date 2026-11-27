# 統合後の操作と移行

## 構成とビルド

正本は `jinji/nixos-config`、作業ディレクトリは各機の `~/nixos-config` とする。
旧 `servers-config` の checkout や稼働中サービスは、この変更だけでは削除・変更されない。

| ホスト | セレクター | 実行環境 | カーネルのビルド環境 |
|---|---|---|---|
| Inspiron 5425 | `inspiron5425` | x86_64-linux | x86_64-linux + ccache |
| Ryzen | `ryzen` | x86_64-linux | x86_64-linux |
| ROCK 3B | `rock3b` | aarch64-linux | x86_64-linux → aarch64-linux + ccache |
| Cubie A5E | `cubiea5e` | aarch64-linux | x86_64-linux → aarch64-linux + ccache |

```console
nix develop
nix fmt
statix check .
deadnix --fail .
nix flake check
nix build .#nixosConfigurations.ryzen.config.system.build.toplevel
nix build .#rock3b-image --out-link result-rock3b-image
nix build .#cubiea5e-image --out-link result-cubiea5e-image
```

イメージは `rock3b-nvme.img`・`cubiea5e-nvme.img`。既存の U-Boot を利用する。
ビルド・VM テストは実機へ設定を適用しない。ARM カーネルを実際にビルドする機械には
`modules/system/nix/ccache.nix` が必要。Ryzen は既存の `/srv/kernel/ccache` を継続利用する。
Inspiron の builder 登録も x86_64・aarch64 の両方を指定する。
ARM のユーザーランド生成には Ryzen の既存の binfmt エミュレーションを使う。

## CI とキャッシュ

`.forgejo/workflows/nix-cache.yml` の一つのワークフローで全ホストを扱う。
ビルド対象の正本は `scripts/nix-cache-targets`（4台の system closure と2種類のイメージ）。
公開鍵は `modules/system/nix/cache.pub`。既存の laptop・server の鍵が同じことを確認して統合した。

- main への push: checks → 全対象ビルド → 署名公開 → 公開キャッシュの署名検証。
- JST 03:00 / 15:00 または手動 `update_lock`: lock 更新 → checks → 全対象ビルド → 署名公開・検証 → lock の push。
- main が進んだ場合は、新しい main を元に最大3回やり直す。未検証の lock は push しない。

runner は既存の `ryzen-nix-build` を継続利用する。登録ファイルと作業領域も維持する。
ワークフローは checkout 内の更新スクリプトを使うので、旧インストール済み updater に依存しない。
署名は既存の `nix-cache-publish` を経由し、秘密鍵を CI ユーザーへ渡さない。
公開グループは `nixos-config` に統一する。既存の `servers-config` グループの記録は書き換えず、
既存 GC の保持方針で管理する。

## 実機への移行（別途、利用者が行う作業）

1. 統合後の変更をレビューし、ビルドと checks を確認して正本へ push する。
2. 旧 `servers-config` 側の定期 CI を停止する。両方の lock 更新を並行運用しない。
3. 各サーバーに統合リポジトリを `~/nixos-config` として準備する。
4. Ryzen を適用する場合は `nix develop -c deploy .#ryzen` を使う。
   新設定ではサーバー専用 runner を廃し、Nix runner と Web runner を残す。
   旧 runner の状態ディレクトリや token はこのリポジトリから削除しない。
5. ARM 機は個別の起動・ディスク手順に従って適用する。
   適用後の `NH_FLAKE` と `/etc/nixos` は統合 checkout を参照する。
6. Inspiron の適用後は OS ホスト名も `inspiron5425` になる。
   `nsr` / `nbr` は新しいセレクターと専用のリモート作業ディレクトリを使う。
   ログインし直して、新しい `NH_FLAKE` をセッションへ反映する。

SSH 接続制限、sudo の認証方針、ディスク UUID、GC の保持期間は統合前の方針を引き継ぐ。
古い `docs/` の移行記録に旧リポジトリ名・旧 runner 名が出る場合、現在の操作は本ページを優先する。
