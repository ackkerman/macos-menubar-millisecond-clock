# spec.md — MenubarMsClock（macOS Menu Bar Millisecond Clock）

## 1. 概要
macOS のメニューバー（NSStatusItem）に現在時刻を **ミリ秒（SSS）まで**表示する、最小構成の常駐アプリを実装する。

- 表示形式: `HH:mm:ss.SSS`
- UI: メニューバー文字列のみ（追加機能なし）
- 開発: Swift + AppKit
- ビルド/実行: SwiftPM（Xcode GUI 不使用）
- 配布対象: ローカル利用（署名/Notarization は対象外）

## 2. ゴール / 非ゴール

### ゴール
- メニューバーに `HH:mm:ss.SSS` を継続表示できる
- Dock に表示しない（常駐）
- CPU負荷が過剰にならない範囲で高頻度更新（ミリ秒の変化が見える）

### 非ゴール（実装しない）
- 設定画面
- クリック操作・メニュー（Quit含む）
- NTP補正、ズレ表示
- 秒単位/フォーマット切替
- アップデータ、インストーラ
- Apple公証（Notarization）や配布

## 3. 要件

### 3.1 機能要件
1. 起動するとメニューバーに時刻が表示される
2. 表示は `HH:mm:ss.SSS` 固定
3. 表示更新が継続的に行われ、ミリ秒が変化して見える
4. Dock に表示されない（アクセサリ常駐）
5. アプリ終了はユーザーが `kill` / `Activity Monitor` / `Cmd+Q` 等で行える（UIからのQuit提供はしない）

### 3.2 非機能要件
- 更新頻度はデフォルトで **10ms**（実装値）とし、必要に応じて調整可能な定数として保持する
- 更新は Main Thread 上で UI 更新を行う
- 文字の桁揺れを避けるため、フォントは **monospaced digit** を使用する
- メニューバー更新が詰まってもクラッシュしない（例外を起こさない）
- macOS 13+（目安）をターゲット（実際の最小対応は実装/SDKに依存）

## 4. 画面/UI仕様
- メニューバーのアイテムは文字列のみ
- 例: `12:13:01.205`
- アイコンなし
- 追加メニューなし

## 5. 技術仕様

### 5.1 アーキテクチャ
- `NSApplication` + `NSApplicationDelegate`
- `NSStatusBar.system.statusItem(withLength: .variableLength)`
- `DispatchSourceTimer` で周期更新
- `DateFormatter` でフォーマット固定
- `NSFont.monospacedDigitSystemFont` を適用

### 5.2 更新ループ
- Timer:
  - queue: `DispatchQueue.main`
  - repeating: `10ms`（`DispatchTimeInterval.nanoseconds(10_000_000)`）
  - leeway: `1ms` 目安
- handler:
  - `Date()` を取得
  - `formatter.string(from:)` を生成
  - `statusItem.button?.title` に代入

### 5.3 Dock 非表示
- `NSApp.setActivationPolicy(.accessory)` を使用
- `.app` 化する場合は `Info.plist` に `LSUIElement = true` を設定

### 5.4 ビルドとパッケージング
- SwiftPM プロジェクト
- `swift build -c release`
- `.build/release/MenubarMsClock` を `.app` にラップ
- ローカル用途の ad-hoc codesign（任意）
  - `codesign --force --deep --sign - MenubarMsClock.app`（失敗しても起動できる場合がある）

## 6. ディレクトリ構成（最小）
```

MenubarMsClock/
Package.swift
Sources/
MenubarMsClock/
MenubarMsClock.swift
make_app.sh   (任意)
spec.md

```

## 7. 受け入れ基準（Acceptance Criteria）
1. `open MenubarMsClock.app` で起動できる
2. Dock にアイコンが表示されない
3. メニューバーに `HH:mm:ss.SSS` が表示される
4. 表示が停止せず、ミリ秒が変化して見える
5. 長時間動かしてもクラッシュしない（最低 30 分）

## 8. テスト方針
本プロジェクトは UI（メニューバー）表示が主であり自動テストの価値が低いため、最小のテストのみ行う。

### 手動テスト
- 起動確認
- Dock非表示確認
- 1分以上の連続更新確認
- CPU使用率確認（Activity Monitor）

### 自動テスト（任意）
- `DateFormatter` のフォーマットが期待通りかのユニットテスト（Pure Swift）
  - ただし AppKit 依存を避けるため、formatter生成を関数化してテスト可能にする

## 9. 実装メモ / 既知の注意点
- 1ms更新は UI 描画やメニューバー更新が律速になることが多く、CPUを無駄に消費しやすい
- 10ms（または 16.6ms/60Hz）程度が現実的
- メニューバー領域は幅制約があるため、表示は時刻のみ固定とする
