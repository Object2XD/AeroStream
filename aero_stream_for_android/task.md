# Refactoring Task Tracker

このファイルは段階導入リファクタリングの進捗管理を行う。  
表記ルール:
- `[x]` 完了
- `[ ]` 未完了

---

## Phase 0: ベースライン固定

- [x] P0-W1: Phase 0 は達成不可能タスクとしてクローズ（後追い時点で真のベースライン要件を満たせない）
- [x] P0-W2: 後追い取得物は「参考資料」として保持し、正式ベースラインとしては使用しない
  - 参照: `baseline_screenshots/README.md`
- [x] P0-W3: 以降フェーズは「P0の正式達成を前提にしない」運用へ切替
- [x] P0-6: Phase 0 クローズチェック（達成不可能判定 + 運用切替が反映済み）

## Phase 1: UIコンポーネント統一（高優先）

- [x] P1-1: `SettingsScreen` トップバーを `AeroTopBar` に統一
- [x] P1-2: `SmbConfigEditorSheet` を `AeroModalSheet + AeroSheetScaffold` へ移行
- [x] P1-3: `SearchScreen` の検索クリア操作を `AeroIconActionButton` に統一
- [x] P1-4: `SmbBrowserScreen` の検索クリア操作を `AeroIconActionButton` に統一
- [x] P1-5: `RootViewModelTest` の期待値を現仕様（`Search + Settings`）に更新
- [x] P1-6: `:app:compileDebugKotlin` 通過
- [x] P1-7: `:app:compileDebugAndroidTestKotlin` 通過
- [x] P1-8: `:app:testDebugUnitTest` 通過
- [x] P1-9: 主要画面の「直書きUI」残件を棚卸し
  - 残件:
    - `SettingsSmbComponents.kt` の `IconButton`（パスワード表示トグル）
    - `SettingsSmbComponents.kt` の `Button`（接続テスト）
    - `SettingsSmbComponents.kt` の `Button`（保存）
  - 判断:
    - いずれもフォーム固有の明示アクションであり、現時点では許容（将来 `AeroPrimaryActionButton` への統合候補）
- [x] P1-10: Phase 1 完了チェック（P1-1〜P1-9 が完了）

## Phase 2: 巨大ファイル分割と責務整理（中優先）

- [x] P2-1: `SettingsScreen.kt` から SMB関連UIを分離
- [x] P2-2: `AeroDesignComponents.kt` から入力系を `AeroInputComponents.kt` へ分離
- [x] P2-3: `AeroDesignComponents.kt` からTopBar系を `AeroTopBarComponents.kt` へ分離
- [x] P2-4: `AlbumDetailScreen.kt` を配線専用化し `AlbumDetailComponents.kt` を追加
- [x] P2-5: `SmbConnectionManager.kt` の診断責務を `SmbConnectionDiagnostics.kt` へ分離
- [x] P2-6: `SmbMediaDataSource.kt` のメタデータ抽出責務を `SmbMetadataExtractor.kt` へ分離
- [x] P2-7: `SmbMediaDataSource` のスキャン進捗更新ロジックを分離
- [x] P2-8: `SmbConnectionManager` の接続ライフサイクル管理を分離（必要なら実施）
- [x] P2-9: `:app:compileDebugKotlin` 通過
- [x] P2-10: `:app:testDebugUnitTest` 通過
- [x] P2-11: Phase 2 完了チェック（P2-1〜P2-10 完了 + レビュー承認）

## Phase 3: SMB/キャッシュ状態モデル整合（中優先）

- [x] P3-1: `isCached` 中心の状態判定を画面横断で統一
- [x] P3-2: 画面間（SMB一覧 / AlbumDetail / Downloads）の表示差異を解消
- [x] P3-3: 重複ロジックを共通化
- [x] P3-4: `:app:compileDebugKotlin` 通過
- [x] P3-5: `:app:testDebugUnitTest` 通過
- [x] P3-6: 対象 UI/VM テスト通過
- [x] P3-7: Phase 3 完了チェック（P3-1〜P3-6 が完了）

## Phase 4: テスト拡充と運用定着

- [x] P4-1: UI回帰テストを追加
- [x] P4-2: ViewModel回帰テストを追加
- [x] P4-3: `design.md` 準拠チェック運用ルールを確定
- [x] P4-4: 最終サマリを記録
- [x] P4-5: `:app:compileDebugKotlin` 通過
- [x] P4-6: `:app:compileDebugAndroidTestKotlin` 通過
- [x] P4-7: `:app:testDebugUnitTest` 通過
- [x] P4-8: Phase 4 完了チェック（P4-1〜P4-7 が完了）

---

## 完了条件（全体）

- [x] G-1: Phase 0 クローズ（達成不可能判定で終了）
- [x] G-2: Phase 1 完了
- [x] G-3: Phase 2 完了
- [x] G-4: Phase 3 完了
- [x] G-5: Phase 4 完了
- [x] G-6: 破壊的変更なし（公開契約維持）を確認
- [x] G-7: `design.md` / `document.md` / `task.md` の整合確認

---

## 失敗記録

- 2026-03-07 / Codex
  - 内容: 手順順守違反。Phase 0 の基準スクリーンショットを、既存変更の後に取得してしまった。
  - 影響: `P0-1` だけでなく、`P0-2`〜`P0-5` も後追い記録となり、Phase 0 全体の正当性が失効。
  - 是正: Phase 0 を達成不可能タスクとしてクローズし、後追い取得物は参考資料へ格下げした。
  - 再発防止:
    - 手順順守を最優先とし、順序の入れ替えを禁止する。
    - 未完了フェーズを飛ばして次フェーズを実施しない。
    - 手順逸脱の兆候が出た時点で即時停止し、`task.md` に先に記録してから再開する。
    - 上記ルールは今後の全タスクで厳守する（例外なし）。

---

## Phase 4 最終サマリ

- 追加テスト
  - UI: `SongListItemTest`（SMB未キャッシュ/キャッシュ済みのアイコン表示回帰）
  - ViewModel: `DownloadsViewModelTest`（キャッシュ済み曲反映・Completed除外・再試行configID）
- ドキュメント整備
  - `design.md` に `Design Compliance Check` を追加し、準拠チェック項目と必須コマンドを明文化
- 検証結果
  - `:app:compileDebugKotlin` 成功
  - `:app:compileDebugAndroidTestKotlin` 成功（`--no-daemon` で確認）
  - `:app:testDebugUnitTest` 成功（`--no-daemon` で確認）
