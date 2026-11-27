# サーバー構成

このリポジトリで Ryzen・ROCK 3B・Cubie A5E と Inspiron 5425 を管理する。
全ホストは共通の `nixpkgs` input を使い、ハードウェア・SSH・sudo・GC の方針は各ホストで維持する。

- [統合後の操作・CI・移行手順](operations.md)
- [Cubie A5E の NVMe 構成・起動準備](cubiea5e.md)
- [Ryzen SSD・RAID 復旧](ryzen-storage-recovery.md)
- [Immich の運用](immich.md)
- [リモートビルダー](nix-remote-builder.md)
- [Binary Cache の導入記録](nix-binary-cache.md)
- [Forgejo の移行記録](forgejo-migration.md)
- [Actions Runner の登録](forgejo-runner.md)
- [Web 公開・デプロイ](web-deployment.md)

旧リポジトリの履歴資料は [ロードマップ](servers-roadmap.md)、
[ROCK の移行記録](rock3b-migration.md)、[Forgejo・キャッシュ移行記録](servers-cache-migration.md)に残す。
取り込んだサーバー構成のライセンスは [servers-LICENSE](servers-LICENSE) を参照。
