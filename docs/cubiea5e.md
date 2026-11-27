# Cubie A5E（NVMe）

構成名・ホスト名は`cubiea5e`。aarch64のNixOSをNVMe上のext4から起動する。
有線LANはNetworkManagerのDHCPを使用し、インターフェース名やMACアドレスは固定しない。
ユーザー`jinji`、fish、CLI、公開鍵とLAN・Mesh範囲に限定した管理SSHは共通モジュールを利用する。
WiFi・Bluetooth・デスクトップは有効にしない。

## 起動の前提

NVMeのイメージだけでは起動しない。SPI NORまたはmicroSDに、Cubie A5Eの
PCIe/NVMeとextlinuxの読み込みに対応したU-Bootが必要。
ブートローダーの準備は[ボード対応プロジェクトの手順](https://github.com/patryk4815/nixos-cubie-a5e#spi-nor-flashing)を参照する。
mainline U-Bootは1 GBモデルと2 GB/4 GBモデルでDRAM設定が異なるため、実機の容量に合うものを使用する。
本リポジトリのビルド・検証は実機やSPI NORを書き換えない。

ボード対応パッチは`cubiea5e` inputとしてrevisionとhashを`flake.lock`に固定する。
上流のflake全体やdiskoは取り込まず、PCIe/Combo PHY、温度センサー、CPU DVFSなどの
ボードモジュールを既存のnixpkgs・`linuxPackages_latest`と組み合わせる。
パッチ済みカーネルはx86_64からaarch64へクロスコンパイルし、カーネルのコンパイルでは
QEMUを使用しない。ユーザーランドは通常のaarch64パッケージのままとし、公式キャッシュを利用する。
Combo PHYはPCIeモードのため、共有するUSB 3.0 SuperSpeedは使用できない。
USB 2.0は使用可能。HDMIによるコンソールは前提にしない。
シリアルコンソールはUART0、115200 baud（`ttyS0`）。

## 検証・イメージ生成

```sh
nix develop
statix check .
deadnix --fail .
nix flake check --no-build
nix build --no-link .#checks.x86_64-linux.cubiea5e
nix build .#cubiea5e-image --out-link result-cubiea5e-image
```

`cubiea5e`のcheckは、カーネルと設定生成のビルド先がx86_64、出力先とユーザーランドがaarch64であること、
実際に使用するカーネルへのパッチ適用、Device TreeとSPI NOR overlayのコンパイル・結合、
PCIeの有効化を確認する。実機の起動確認は別途必要。
カーネルの生成にはx86_64ビルダーが必要。その他のaarch64ビルドには、
aarch64のネイティブ環境、リモートビルダー、またはbinfmtが必要。
既定ビルダーがx86_64専用かつ`max-jobs = 0`なら、binfmtが有効なホストで次を使用する。

```sh
nix build --builders '' --max-jobs 2 --cores 2 \
  .#cubiea5e-image --out-link result-cubiea5e-image
```

生成物は`result-cubiea5e-image/cubiea5e-nvme.img`。
MBR・単一ext4パーティションに、extlinux、カーネル、initrd、Device Tree、
Nixストアとsystemプロファイルを含む。U-Bootは含めない。
初回起動時にルート領域を拡張し、4 GiBのswapファイルを作成する。

ルートFSのUUIDは`a527a5e0-0000-4000-8000-000000000001`。
既存のNVMeに直接インストールする場合は、`hosts/cubiea5e/hardware-configuration.nix`の
`fileSystems."/".device`を実際のUUIDへ変更する。イメージを使う場合は変更不要。

## 初回起動後

現在の構成では、`initrd-pcie-gen1.service`がPCI列挙後、モジュール読み込み・udev
coldplug・ルートFSのマウントより前に、確認済みのNVMeをGen1へ切り替える。
DTBの`max-link-speed`は変更せず、Target Link Speedの変更とRetrain Linkを使う。
Cubie A5E・SSSTC `1e95:1007`・既知のPCI設定を確認し、すでにドライバがバインドされた
デバイスは再訓練しない。Gen1のトレーニング完了とPCI設定の維持を検証し、異常時はサービスを失敗させる。
CPUFreq・ASPM・APSTの無効化も、実機で成功した比較条件として維持している。
通常起動は自動で進み、initrdで停止させる手動の`rd.systemd.mask`は使わない。
カーネル指定は`linuxPackages_latest`で、固定中のnixpkgsでは7.3.1となる。
7.3で追加されたCCUのIOSC calibrationフラグとCPU CCUバックポートのbit 12が衝突するため、
CPUパッチの該当フラグをbit 13へ移し、同じ箇所のパッチ文脈も調整する。
7.3.1への全パッチ適用・Device Treeコンパイル・CCUフラグの非衝突・Gen1回避策のfixtureは検証済み。
下記の世代6で実機確認したカーネルは7.2.15で、7.3.1の実機起動は未確認。

### initrdでの起動診断

`initrd-debug.nix`で、ルートFSをマウントする前から両方の有線LANとDHCP・SSHを有効にする。
MAC用に`dwmac-sun8i`・`dwmac-sun55i`をinitrdで読み込む。
実機の両PHYのIDは`0x7b744412`で、`Generic PHY`により1 GbpsでのリンクとDHCP取得を確認した。
初期のYT8531想定で追加した`motorcomm`も診断構成に残っているが、この実機にはバインドしていない。
DHCPホスト名は`cubiea5e-initrd`。ルーターのリース一覧でIPアドレスを確認し、
共通設定に登録した`jinji`の公開鍵に対応する秘密鍵で接続する。

```sh
ssh -p 2222 root@IPアドレス
```

SSH接続後に、NVMe・PCIeの検出とルートFSの待機状態を確認する。

```sh
ip -br address
lspci -nn
lsblk -f
dmesg
journalctl -b --no-pager
systemctl --failed
systemctl status sysroot.mount
```

ホスト鍵は起動時にRAM上で生成し、イメージやバイナリキャッシュには秘密鍵を含めない。
再起動でホスト鍵が変わるため、既知の機器であることを確認したうえで、必要なら
`ssh-keygen -R '[IPアドレス]:2222'`で古い登録を削除する。
initrdのSSHは鍵認証のみ。ルートFS待機が失敗してemergency modeに移っても、ネットワークとSSHを維持する。
通常の起動が完了するとinitrdのSSHは終了し、以降は下記の`jinji`・ポート22を使用する。
カーネルがinitrdを実行する前に停止する場合、この診断用SSHも起動しない。

initrd開始の目印として、`initrd-led-marker.service`がモジュールの読み込み・ルートFSの
マウントより前にステータスLEDを常時点灯にする。GPIO LEDドライバはカーネル組み込み。
DTB側の緑LEDも常時点灯にした試験では、緑だけの点灯と青も点灯する段階を区別できる。
NVMe上の`cubiea5e-stage-marker.dtb`は、PCIe・Combo PHYを無効にしたDTBに、緑LEDの
`linux,default-trigger = "default-on"`を追加した試験用コピー。元のDTBは残している。
PCIeの再有効化試験では`cubiea5e-pcie-debug.dtb`を使う。LED設定を維持し、
`/soc/pcie@4800000`と`/soc/phy@4f00000`の`status`だけを`okay`へ戻したもの。
USBログ採取用initrdは再利用し、extlinuxの`FDT`参照だけを切り替える。
切り替え前の設定は`extlinux.conf.before-pcie-restore`に保存している。
MSIの切り分け試験では、NVMe上のextlinuxの`APPEND`へ`pci=nomsi`だけを追加する。
追加前の設定は`extlinux.conf.before-nomsi`に保存している。電源を完全に切った状態から
起動し、NVMeの`Identify Controller`タイムアウトが再現するかをUSBログ・SSHで確認する。
この引数はNVMe上だけの試験設定で、Nixの構成には追加していない。

割り込みレジスターの採取試験では`pci=nomsi`を外し、MSIを有効に戻す。
`cubiea5e-initrd-pcie-register`には`devmem`を含め、Cubie A5EでのみPCIeコントローラーの
MSIアドレス・各バンクのenable/mask/status・INTxのmask/statusを32 bit幅で読み取る。
レジスターへの書き込みは行わない。読み取りには診断用の`iomem=relaxed`を使用する。
起動直後の値は`pcie-initial.txt`、最新の値・割り込みカウンター・PCI設定は`pcie.txt`へ保存する。
`rd.systemd.mask=initrd-cleanup.service`で通常起動への移行を止め、initrdのSSHを維持する。
この試験では通常のポート22ではなく、`root`・ポート2222で接続する。
変更前のextlinux設定は`extlinux.conf.before-pcie-register`に保存する。

ASPMの切り分けでは`cubiea5e-initrd-aspm-debug`と`pcie_aspm=off`を使い、MSIを有効に保つ。
このカーネル引数はファームウェアのASPM設定を残すため、Cubie A5EのNVMeとルートポートの
Link Controlも`setpci ... CAP_EXP+10.w=0:3`で変更し、L0s・L1だけを無効にする。
変更前後の値はUSBの`aspm.txt`へ保存する。通常起動への移行停止は維持する。
NVMeには`/var/log/journal`を作成し、通常起動側のログも保存できるようにする。
変更前のextlinux設定は`extlinux.conf.before-aspm-debug`に保存する。

USBなしの起動確認には`cubiea5e-initrd-optional-usb`を使う。
実機ではカーネルが割り当てたNVMeのBARと、ルートポートのバス番号・Commandが
ゼロへ戻っており、これらを復元するとNVMeの認識・読み書きが可能になった。
`initrd-pcie-recover.service`は、機種・NVMeのID・割当済み領域と失われた値が
確認時と一致する場合だけ、udevによる初期認識が完了してから同じ設定を復元し、
NVMeを再プローブする。初期認識より前の復元では、その後に再度設定が失われた。
モジュール読み込み・udevのcoldplug後に、改めてudev処理の完了を待って確認する。
既にNVMeドライバが接続されていても、同じPCIe設定の消失を確認した場合は
ドライバを切り離してから復元し、再接続する。復元はルートFSのマウントより前に行う。
これは診断用の回避処理で、PCIe設定が失われる原因は未解決。
ASPM無効化だけでは認識失敗を防げず、MSIは有効にしたまま試験する。

PCIe初期化の追加試験では、Linux 7.2のボード対応パッチ適用後に
`patches/sunxi-pcie-link-training.patch`を適用する。実速度はPCI ExpressのLink Statusから
取得し、常に0を返していた処理を修正する。RC設定末尾の無条件な速度変更要求を外し、
速度変更処理へまとめる。要求完了とリンクの再確立・トレーニング終了を確認してから
デバイスを列挙し、タイムアウトはホスト初期化のエラーとして返す。
`PCIe diag`のログには初期化・速度変更・列挙の前後のリンク状態、Command、
バス番号と、列挙後の各デバイスのBARを記録する。

速度取得・リンク待ち修正後の実機試験でも、initrdの復旧処理が必要だった。
列挙直後にはGen2、RC Command=`0507`、バス番号=`00ff0100`、
NVMe BAR=`22000004`が維持されていたが、その後のNVMe初期認識で
`-ENODEV`となり、復旧処理が実行された。通常起動後の速度はGen1・×1。
単に速度取得・リンク待ちを修正するだけでは、PCI設定消失は解消しなかった。

時刻の比較にはkernelメッセージの`_SOURCE_MONOTONIC_TIMESTAMP`を使う。
`journalctl -o short-monotonic`は初期ログの取り込み時刻を表示しており、
以前の約3.57秒という表示は列挙時刻ではなかった。復帰後のログではカーネル元時刻で
列挙完了が約1.13秒、`/init`開始が約1.45秒、NVMe初期認識失敗が約6.88秒だった。

次の比較試験ではDevice Treeの`max-link-speed = <1>`でGen1に固定した。
カーネル・initrdは同じ生成物を使い、DTBの検証も通ったが、再起動後にDHCP取得が
確認できず、通常SSH・initrd用SSHも応答しなかった。停止段階と原因は未確認。
Gen1固定のoverlayと適用設定は取り下げ、前回起動できたGen2指定の構成へ戻す。
既存のinitrd復旧処理と診断用引数は維持する。
失敗回の新しいjournalはNVMe上にも残っていなかった。PCへ接続して
extlinuxの`DEFAULT`を`nixos-2-default`へ戻し、systemプロファイルも世代2へ戻した。
Gen1試験時の起動設定は`/boot/extlinux/extlinux.conf.gen1-failed.1iK7w8`へ退避済み。
復帰後は通常起動を確認し、起動18.825秒、失敗サービス0、NVMeルートの読み書き可能な
マウントを確認した。ただしPCI設定復元は引き続き実行され、通常起動後のリンクもGen1・×1。
Gen1固定を外すと前の動作へ戻ったが、PCI設定消失の原因は未解決。

続く観測試験では`initrd-pcie-watch.service`が最初のPCI設定を保存してから
`systemd-notify --ready`を送り、モジュール読み込みとudev coldplugの開始を許可する。
以降は100msごと（読み取り時間を除く）にRoot PortのCommand・バス番号・Link Status、
NVMeのBAR、モジュール一覧を読み、変化した状態を採取開始・終了のuptimeとともに記録する。
PCI設定は読み取りだけとし、復元は既存のサービスが引き続き担当する。

既存カーネルの`trace_event`でinitcall・module load・clock・PCIe linkのイベントも
起動時から採取する。通常起動への切り替え時（または最大約20秒の採取終了時）に
観測を止め、trace bufferを保存する。`/run/cubiea5e-pcie-watch.log`と
`/run/cubiea5e-pcie-trace.txt`を通常起動後に回収し、元のカーネル時刻で照合する。
この試験ではカーネルの再ビルドやリンク速度の変更は行わない。

観測試験は正常起動し、失敗サービス0、起動19.205秒だった。最初の採取
（uptime 3.58〜3.61秒、モジュール一覧が空）で既にRC Command・バス番号が0、
NVMe BARが`00000004`へ戻っていた。カーネル元時刻では約1.16秒の列挙直後まで
設定が正常だったため、消失はその後から最初の採取までの間に起きている。
今回の再現では、LAN・NVMeモジュールの初期化より前に消失している。
約7.37秒に既存の復旧処理が実行され、通常起動へ進んだ。
ログは実機の`/home/jinji/cubiea5e-pcie-watch-result.xIl8JD/`へ保存済み。

trace bufferは7877件を全件保持していた。設定消失までにPCIeの`usb3-ref`・
`pcie-aux`を停止するclock操作は記録されていなかった一方、CPUの`pll-cpul`・
`pll-cpub`は頻繁に周波数を変更していた。PCIeデバイスとコントローラーの
runtime suspend時間も0だったが、これだけで他のリセットや電源操作は除外できない。
次の比較では`cpufreq.off=1`を追加し、CPUFreq coreによる動的周波数変更を止める。
既存のPCIe速度設定・復旧処理・観測は維持し、CPUFreq policyの有無、CPU PLLの
周波数変更イベント、PCI設定消失と復旧処理の有無を確認する。DVFSとの関係は未確定。

CPUFreq無効化の初回試験では、最初の採取（uptime 3.90〜3.93秒）から通常起動へ
切り替える直前までRC Command=`0507`、バス番号=`00ff0100`、Gen2、
NVMe BAR=`22000004`が維持された。NVMeは初回プローブで認識され、PCI設定の
復元処理は不要だった。ただし通常起動後のSSHは認証前に切断され、initrd用SSHも
終了済みだったため、NVMeをPCへ接続してログを回収した。

通常起動側は開始されているが、保存されたjournalは約17.28秒の初回flush付近で
終わっており、SSH切断の原因は未確定。`sshd`・`sshd-session`のハッシュは正常な
ビルドと一致し、`/etc/passwd`、`/var/empty`、`/var/run`に以前の異常はなかった。
CPUFreq無効化で初期PCI設定消失が再現しなかったのは有力な比較結果だが、DVFSそのものと
起動タイミングの変化のどちらが効いたか、通常起動後もPCIeが安定するかは未確認。

次の試験はNVMeのextlinuxの既定エントリーにのみ
`rd.systemd.mask=initrd-cleanup.service`を追加し、CPUFreq無効のままinitrdで停止する。
通常起動へ進む前にRAM上のSSH（root・2222番）からNVMeのI/Oと通常起動側のSSHを調べる。
カーネル・initrd・DTB・Nix systemプロファイルは変更しない。
変更前の起動設定は`/boot/extlinux/extlinux.conf.no-dvfs-normal.mg3eI2`へ保存済み。
通常起動へ移す際は`systemctl isolate initrd-switch-root.target`で標準のudev後処理と
NixOS activationを通す。`systemctl switch-root`だけを直接実行しない。
ROCK用パッチ、SPIの更新、Linux 7.3への更新はこの試験に含めない。

initrd停止試験（boot ID `c3434399-82ab-4bb4-af3e-ac3fa8d07099`）では、
CPUFreq無効のままGen2とPCI設定が維持された。約12分後にもNVMeからの256MiBの
direct readが約412MB/sで成功した。通常ルートの`sshd -t`も成功し、
一時ポートで通常ルートのsshdを動かした際の鍵交換も成功した。

続いてnetconsoleを一時的に有効にし、通常起動への移行ログをPCへ直接送った。
標準の`initrd-switch-root.target`で移行したが、移行開始から約42秒後に
NVMeのI/Oエラーが発生し、ext4のjournalが中止され、読み取り専用へ再マウントされた。
sshdにも`sshd-session failed: Input/output error`が記録された。
通常起動後のSSH不調にNVMeのI/O障害が関わっていることを確認できたが、
通常起動後のPCI設定・リンク状態は未採取で、障害の起点はまだ分かっていない。
NVMeのstatus `sct 0x3 / sc 0x71`はホスト側のコマンド中止を表し、
これだけでSSDのメディア故障とは判断できない。

NVMeをPCへ接続してjournalを退避した後、`e2fsck -p`でjournalを回復した。
その後の`e2fsck -f -n`は全5パスをエラーなしで完了した。
USB接続時のSMARTはCritical Warning=0、Media and Data Integrity Errors=0だった。
ログはPCの`/tmp/cubiea5e-held-initrd.c1wLvn/`に保存している。
netconsoleとjournaldの転送設定はRAM上だけの変更で、次回起動には残さない。

次の比較試験は、extlinuxの既定エントリーにのみ
`nvme_core.default_ps_max_latency_us=0`を追加し、NVMeのAPSTを無効にする。
CPUFreq無効、既存のASPM無効、Gen2指定、カーネル・initrd・DTBは維持する。
`rd.systemd.mask=initrd-cleanup.service`も付け、まずinitrdで設定とPCI状態を確認する。
変更前の起動設定は`/boot/extlinux/extlinux.conf.before-apst-off-c3434399`へ退避済み。
これは手動の比較用設定で、`nixos-rebuild boot`では上書きされる。

APST無効の試験（boot ID `596aeadf-d7e9-4314-a2e8-a491f1619615`）では、
initrdで`nvme_core.default_ps_max_latency_us=0`の反映とNVMeの`live`を確認した。
通常起動開始直後（uptime約382.70秒）もRC Command=`0507`、
バス番号=`00ff0100`、NVMe BAR=`22000004`、Gen2だったが、移行開始から
約42秒後に再びNVMeのI/O中止とext4のjournal中止が発生した。
APST無効化だけでは通常起動後の障害を防げなかった。
通常起動用の観測ログは最初の採取以降PCへ届かず、障害時点のPCI状態は未確認。
NixOSは通常起動のsysctlで`kernel.printk=4`へ戻すため、情報レベルの
netconsoleログが非表示になった可能性もある。次の観測では出力レベルを維持し、
実行ファイルと共有ライブラリもRAMへ置いてNVMeへの依存を外す。
ログはPCの`/tmp/cubiea5e-apst-off.fmM47h/`へ保存した。
extlinuxのinitrd待機設定は維持し、次回は電源を入れ直して診断用SSHへの復帰を試す。

RAMからの観測試験（boot ID `43d4c788-2209-4ba6-85dc-d2aa0fc0f96d`）で、
通常起動後にもPCI設定が消失することを確認した。`bash`・`setpci`・`sleep`と
共有ライブラリを`/run`へ複製し、RAM上のdynamic loaderから実行した。
観測ログはjournaldを経由せず`/dev/kmsg`へ直接書き、sysctlのログレベルも8に維持した。
これらはその起動中だけの設定で、次回起動へは残さない。

CPUFreq・APST無効のまま、uptime約324.82秒の通常起動開始直後にはPCI設定が正常だった。
約330.19秒にはRC Commandとバス番号が0、NVMe Commandも0、BARも`00000004`へ戻り、
リンクはGen2からGen1へ変わった。この後はNVMeの全キューの割り込み数が増えず、
約361.45秒に`controller is down; will reset: CSTS=0xffffffff`となり、
約363.05秒にはNVMeが`dead`になった。PCI設定消失はNVMeのタイムアウトより先に起きている。
CPUFreq無効化は初期の消失を抑えたが、通常起動後も含めた根本対策にはなっていない。
ログはPCの`/tmp/cubiea5e-ram-watch.ZK3tbq/`に保存した。
次はinitrdのままCPU負荷とNVMe読み出し負荷を分けて与え、通常起動のサービスを
開始しなくてもPCI設定消失が再現するか確認する。負荷試験中はルートFSを読み取り専用にする。

initrd内の負荷試験（boot ID `54fa74f4-5288-4279-b5e3-8289219c2ba8`）では、
ルートFSを読み取り専用にし、8コアのCPU負荷を20秒、NVMeの8並列direct readを
計4GiB、さらに両方を同時に実行した。全試験でGen2とPCI設定を維持し、
読み出しも成功した。この条件ではCPU負荷・連続読み出し負荷だけでは再現していない。
書き込み負荷や、あらゆる電源・信号品質の問題を除外できたわけではない。

同じ起動で通常起動へ移すと、uptime約383.12秒にPCI設定が再び消失した。
この時点でRoot Port・NVMe・`4800000.pcie`は全てruntime active、
runtime suspend時間も0だった。消失時に採取を止めたtrace bufferは
2832件を全件保持し、クロックの停止・周波数変更やregulator操作のイベントは
見つからなかった。通常起動中のどの操作が消失につながるかは未確定で、
次はカーネルのリセットAPIとPCI設定書き込みを直接観測する。
ログ・負荷試験結果・RAM観測スクリプトはPCの
`/tmp/cubiea5e-initrd-load.Z8tCeL/`へ保存した。

リセット・PCI書き込みのkprobe試験（boot ID `5809d2f7-7c5c-4bf6-b97e-30aba1f4764f`）では、
`reset_control_assert/reset/deassert`、PCI設定のbyte/word/dword書き込み、
`pci_user_write_config_word`、sunxiドライバーの`sunxi_pcie_host_wr_own_conf`と
`sunxi_pcie_wr_conf`を観測した。RC Commandの値を変えない書き込みで、
ユーザー側のPCI書き込みとsunxiのwrite callbackの呼び出し・引数・stack traceが
採取されることを事前確認した。

通常起動後のuptime約183.49秒にPCI設定が消失したが、そこまでのtraceは25件を全件保持し、
上記リセットAPI・PCI書き込みの呼び出しは記録されなかった。
これらの経路でLinuxが設定を消している証拠は得られていないが、全ての直接MMIO操作や
ファームウェア・ハードウェア側の動作まで除外したわけではない。
ログはPCの`/tmp/cubiea5e-reset-probes.*/`（場所は
`/tmp/cubiea5e-reset-probes-dir`に記録）へ保存した。
この試験ではjournaldのkmsg転送を止め、PID 1のLogTargetをkmsgにして観測ログの重複も避けた。
次は未確認のNVMe書き込み負荷を一時ファイルで試し、電源・ケーブルの仕様も確認する。

initrd内の書き込み試験（boot ID `fdb12481-35e8-447a-8e55-d1452f6afe56`）でも、
128MiBのdirect write＋fsync、および8並列・計256回の4KiB direct write＋fsyncは成功した。
PCI設定とGen2を維持し、NVMeも`live`だった。試験用ファイルは削除済み。
電源は利用者申告でUSB PD 30W以上、0.9mのC-to-Cケーブル。5V時の定格は不明。
Radxaの[USB電源仕様](https://docs.radxa.com/en/cubie/a5e/hardware-use/usb)は5V・3A以上を推奨するが、
現時点で電源不足とは断定していない。

同じ起動で、ルートFSを読み取り専用にしてから、DTBは変えずにRoot Portの
Target Link SpeedをGen1へ変更し、Retrain Linkを要求した。
`CAP_EXP+30.w=0001:000f CAP_EXP+10.w=0020:0020`でGen1となり、
RC Command・バス番号・NVMe BARは維持された。64MiBのdirect readも約207MB/sで成功した。
これは起動後のリンク再訓練で、以前失敗したDTBのGen1固定試験とは異なる。

この状態でルートFSを読み書き可能へ戻し、標準の終了処理から通常起動へ移したところ、
`192.168.11.20:22`で通常SSHが成功し、失敗サービス0、NVMeルートは読み書き可能だった。
通常起動開始から約190秒後にもGen1・PCI設定・NVMe・SSHを維持していた。
比較中はCPUFreq・APST無効を維持し、他の診断条件も揃えている。
リンク速度を下げた効果と、再訓練自体の効果はまだ分離できていないため、
次はGen2を指定したまま再訓練する比較を行う。
今回のGen1変更は起動中だけのもので、再起動すると戻る。
extlinuxのinitrd待機設定も残しており、再起動時は2222番の診断用SSHで待機する。
書き込み・Gen1比較のログは`/tmp/cubiea5e-initrd-write.yMtfwl/`へ保存した。
今回の各試験のログ・pcapとRAMツールの準備スクリプトは、PCの
`/home/jinji/cubiea5e-diagnostics-20261116.v9XGIO/`にも退避した。

Gen2のまま再訓練する対照試験（boot ID `056f38d4-35e2-4deb-b705-5d56999833f8`）では、
Target Link Speedを2に維持してRetrain Linkを要求した。
PCI設定を維持したGen2と約405MB/sのdirect readを確認したが、通常起動後の
uptime約82.46秒にはRC Command・バス番号・NVMe BARが再び消失した。
約112.11秒にはNVMeの`CSTS=0xffffffff`とリセットが記録された。
再訓練だけでは回避できず、今回の比較ではGen1への速度低下が効いていると見られる。
ログは`/tmp/cubiea5e-gen2-retrain.0cVrUz/`に保存した。

次の起動（boot ID `f6f8fb8c-b940-4a13-ad6b-cf7e4f8c35b4`）も、initrdでGen1へ切り替えた後、
追加のRAM観測サービスを入れずに通常起動した。`192.168.11.22:22`でSSHが成功し、
失敗サービス0、NVMeルートの読み書き可能なマウント、PCI設定の維持を確認した。
Gen1での通常起動成功は2回となった。ログは`/tmp/cubiea5e-gen1-restored.pXHWC5/`に保存した。
根本原因が信号品質・PHY/ドライバー・ブートローダーからの引き継ぎのどれかは未確定。
この比較結果を受け、DTBのGen1固定を再投入するのではなく、確認できた列挙後のGen1切り替えを
NVMe利用前にinitrdで自動実行する構成を実装した。
Gen1への切り替え・トレーニング待ち・PCI設定の維持、既存の設定消失時の復旧経路への引き継ぎ、
バインド済みデバイスの拒否・タイムアウトをfixtureで検証している。
RyzenでビルドとCubie構成チェックを実施し、世代6
`68jbhyh1jy30bwrbznrmjs7s1fgbfjas-nixos-system-cubiea5e-26.11.20261103.1d06008`を
`nixos-rebuild boot`で配置した。新しいinitrdは`5zd0rsr2fyasggzkaz5cryjmfb61z8ci`。
カーネルとDTBは従来の生成物を使い、手動のinitrd待機引数を外している。
配置前のextlinux設定・systemプロファイル・boot IDは、実機の
`/home/jinji/cubiea5e-auto-gen1-before/`へ退避した。

世代6への再起動（boot ID `178ea92a-0e06-4341-a2e9-3ddf01018224`）を確認した。
手動のリンク操作やswitch-rootは行わず、uptime約4.14秒でGen1切り替えとPCI設定維持の
検証が完了し、約9.48秒にNVMeを認識、約23.17秒にmulti-user.targetへ到達した。
`192.168.11.15:22`で通常SSHが成功し、起動約148秒後も失敗サービス0、NVMeは`live`、
ルートFSは読み書き可能、RC Command・バス番号・NVMe BARを維持したGen1だった。
PCI設定の復元処理やNVMeのI/Oエラーは記録されていない。
ビルド・構成チェック・initrd収録確認・初回起動ログは、PCの
`/home/jinji/cubiea5e-diagnostics-20261116.v9XGIO/auto-gen1/`へ保存した。

試験構成は`nixos-rebuild boot`で次回起動用に配置する。以降はNixが生成したinitrdと
Device Treeを使い、手動配置した診断用ファイルはextlinux更新時に削除される。
配置前に動作していた`/boot`一式は、実機の
`/home/jinji/cubiea5e-before-link-training.uwm7vi/boot.tar.gz`へ退避済み。
比較用ログも同じディレクトリへ保存している。修正前は起動18.449秒、
PCIe Gen1・×1で、initrdによるPCI設定復元が実行されていた。

通常起動の確認ではextlinuxの`rd.systemd.mask=initrd-cleanup.service`と
`rd.systemd.mask=initrd-switch-root.service`を両方外し、標準のinitrd終了処理を通す。
診断用SSH・networkd・USBログ採取は`initrd-switch-root.target`で終了させる。
`systemctl switch-root`だけを直接実行すると初期化済みサービスの状態が引き継がれ、
通常起動側のtmpfiles処理が実行されず、SSHに必要な`/var/empty`などが作成されなかった。
その際に`/var/run`が実ディレクトリとして残り、`nscd`も読み取り専用エラーで失敗した。
実機停止中に内容を退避し、`/var/run`を`/run`へのシンボリックリンクへ戻した。

USBログ採取の試験では、UUIDが`9F30-F9CD`のFAT形式USBメモリにのみ書き込む。
`initrd-usb-debug.service`はバックグラウンドで動き、モジュール読み込み・ネットワーク・
PCIe復元の開始条件にはしない。USBのUUIDリンクが現れた場合だけログ採取を開始し、
約5秒間隔（コマンドの実行時間を除く）で`cubiea5e-boot-XXXXXXXX/`内を更新する。
USBが見つからなければ正常終了する。全ディスクを調べる`blkid -U`は、応答しないNVMeを
待って停止することがあるため使わない。
`dmesg.txt`・`journal.txt`・`status.txt`にカーネルログ・サービス状態・LAN認識状態を保存する。
起動ごとに別ディレクトリを作り、USB上の既存ファイルは残す。
USBメモリを挿してCubieを2〜3分動かした後、電源を切ってPCでログを確認する。
この保存先UUIDとサービスは診断用のため、切り分け後に削除する。

診断用の`clk_ignore_unused pd_ignore_unused`で、ブートローダーが有効にした未使用クロック・
電源ドメインの自動停止を抑える。切り分け後は`initrd-debug.nix`の該当パラメーターを削除する。
NVMe上だけで試す場合は`/boot/extlinux/extlinux.conf`の`APPEND`行に追加でき、
カーネルの再ビルドは不要。直接変更する前のバックアップは`extlinux.conf.before-clock-debug`。

### 通常の起動後

DHCPのリース一覧から接続先IPアドレスを確認し、共通設定に登録済みの鍵で`jinji`としてSSH接続する。
ユーザーパスワードや秘密鍵はイメージに含めない。
一般のsudoを使う場合は、インストール環境で`passwd jinji`を実行するか、管理するパスワード設定を別途追加する。
`nixos-rebuild`には既存のROCK 3Bと同じパスワード不要sudoルールを設けている。

本リポジトリを`/home/jinji/nixos-config`へ配置した後の更新（RyzenへSSH接続できる場合）:

```sh
sudo nixos-rebuild switch --flake /home/jinji/nixos-config#cubiea5e \
  --build-host jinji@ryzen.home.arpa
```

起動後は`lsblk -f`、`ip -br address`、`lspci -nn`、`journalctl -b -k`で
ルートFS・LAN・PCIeを確認し、`/sys/class/thermal/thermal_zone*/temp`で温度の変化も確認する。
再起動動作は使用するTF-Aに依存する。PSCI reset未対応のTF-Aを使用する場合のみ、
上流の`hardware.cubie-a5e.watchdog-reboot`を検討する（shutdown時に意図的にkernel panicさせる回避策）。
