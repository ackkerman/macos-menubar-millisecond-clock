# msbar — macOS Menu Bar Millisecond Clock

macOSのメニューバーに`HH:mm:ss.SSS`で現在時刻を表示する常駐アプリ。Dockには出ず、10ms間隔で更新します（必要なら`Sources/msbar/msbar.swift`内`updateInterval`を16.6msなどに調整してください）。

## 必要環境
- macOS 13+（AppKit）
- SwiftPM（Xcode GUI不要）/ Swift 6 toolchain

## 使い方
```bash
# リポジトリ直下で
make release          # リリースビルド
./make_app.sh         # msbar.app を生成
open msbar.app        # 実行（Dockには出ません）
```

インストールしたい場合は生成された`msbar.app`を`/Applications`へコピーするだけです。
```bash
cp -R msbar.app /Applications/
open /Applications/msbar.app
```
初回はGatekeeper回避のため右クリック→「開く」で実行するとスムーズです。

### Makefileターゲット
- `make build` : デバッグビルド
- `make release` : リリースビルド
- `make run` : 実行（デバッグ）
- `make test` : ユニットテスト（環境にXCTest/macOS SDKが必要）
- `make bundle` / `make app` : リリースビルド→`.app`生成
- `make clean` : ビルド/`.app`片付け

## 実装メモ
- AppKit + NSStatusItem、monospaced digitフォントで桁揺れを防止。
- `DispatchSourceTimer`を10msで駆動しメインスレッドでタイトル更新。
- Dock非表示は`LSUIElement`（Info.plist）と`.accessory`ポリシーで対応。
