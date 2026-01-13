# MenubarMsClock — macOS Menu Bar Millisecond Clock

<p align="center">
  <img src="assets/icon.png" alt="MenubarMsClock icon" width="160">
</p>

超軽量のメニューバー常駐アプリ。現在時刻を `HH:mm:ss.SSS` 形式で10ms間隔更新し、Dockには出ません。`Sources/MenubarMsClock/MenubarMsClock.swift` の `updateInterval` を変えることで 60Hz 相当 (~16.6ms) などにも調整できます。

## 特長
- メニューバーにモノスペース数字で表示（文字幅揺れを抑制）
- クリックで表示フォーマットを即切替（`HH:mm:ss.SSS` / `HH:mm:ss` / `HH:mm` / 上段 `HH:mm:ss` + 下段 `SSS` / `mm:ss.SSS`）
- メニューから「ログイン時に起動」をトグル
- メニューから終了可能、Dock非表示

## 対応環境
- macOS 13+
- Swift 6 ツールチェーン / SwiftPM（Xcode GUI 不要）

## インストールと実行
```bash
make bundle          # Releaseビルド + アイコン生成 + .app 作成
make install         # /Applications に配置（管理者権限不要）
open /Applications/MenubarMsClock.app
```
Gatekeeper の初回警告を避けるには右クリック→「開く」を使用してください。

## 開発者向け
- `make build` : デバッグビルド
- `make run`   : デバッグビルドを実行
- `make test`  : テスト（macOS SDK / XCTest が利用可能な環境が必要）
- `make clean` : ビルド生成物の削除

アイコンについて: `assets/icon.png` から `make` 実行時に自動で `.iconset` / `.appiconset` / `.icns` を生成し、アプリバンドルに組み込みます。

## 実装メモ
- AppKit + `NSStatusItem`、モノスペースフォントで幅揺れを防止
- メインキュー上の `DispatchSourceTimer` を10msで駆動
- `LSUIElement` + `.accessory` で Dock から隠し、メニューバー専用に動作
