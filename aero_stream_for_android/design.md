# Design Policy

## Purpose / Scope

この文書は、Aero Stream for Android のUIデザイン方針を定義します。  
目的は、見た目の一貫性、実装再利用性、過剰装飾の抑制を両立することです。

- 対象:
  - UIコンポーネントの使い分け
  - 画面別のデザイン適用方針
  - アクセシビリティの最低基準
  - デザイン運用ルール
- 非対象:
  - i18nの詳細仕様
  - ドメイン/データ層の仕様
  - ナビゲーション仕様の詳細（`document.md` を参照）

## Design Principles

- 一般的なモバイルUIに寄せ、学習コストを下げる
- 情報密度と可読性を優先し、装飾を目的化しない
- すべてをカード化しない。意味のあるグルーピング時のみカードを使う
- 既存コンポーネントを再利用し、画面ごとの独自実装を最小化する
- UIは原則コンポーネント化する（Component-first）
  - 同一用途のUIは `Aero*` コンポーネントとして集約し、重複実装を避ける
  - まず既存コンポーネントの拡張を検討し、新規作成は最終手段とする

## Component Usage Rules

### `AeroSearchField`

- 検索入力専用
- 上部検索バー、フォルダ内検索などに限定して使用
- 一般フォーム入力には使用しない

### `AeroTextInput` / `AeroFormField`

- 一般入力専用（設定、編集、認証）
- 検索用途では使用しない
- フォーム入力は原則この系統に統一する

### `AeroCard`

- 意味的にまとまった情報ブロックのみで使用
- 通常のリスト行では使わない

### `AeroSingleChoiceOptionRow`

- 単一選択のシートUIで標準採用
- Library Source / Sort / Settings の選択モーダルで統一する

### `AeroListRow`

- 通常のフラットリストの標準行として使用
- アイコン + テキスト + 右アクションを基本構成とする

## Screen-specific Guidelines

### Search

- 検索入力は `AeroSearchField` を使用
- 最近の検索はフラット行 + 区切り線を基本とする
- 結果一覧は既存のリスト体験を維持する

### Settings

- 選択系BottomSheetは `AeroSingleChoiceOptionRow` に統一する
- SMB編集フォームは `AeroTextInput` / `AeroFormField` を使用する
- 設定一覧はカード多用を避け、標準的な行UIを優先する

### SMB Browser

- 一覧は `AeroListRow` を標準採用
- エラー/未設定などの空状態は `AeroEmptyState` を使用
- 検索時のみ `AeroSearchField` を表示する

### Library BottomSheet (Source/Sort)

- BottomSheetの選択肢は `AeroSingleChoiceOptionRow` を使用する
- 単一選択の視認性とセマンティクスを共通化する

## Do / Don't

### Do

- 既存 `Aero*` コンポーネントを優先して再利用する
- 選択UIには `selected` / `stateDescription` を付与する
- アイコンボタンには `contentDescription` を設定する
- 長文は適切に省略し、必要に応じて補助情報を付与する
- 同じUIパターンを2回以上実装する場合はコンポーネント化を検討する

### Don't

- 検索以外の入力で検索窓デザインを使わない
- 通常行を理由なくカード化しない
- 同一用途に複数の見た目ルールを混在させない
- 画面単位で独自の入力コンポーネントを増やさない
- 同一目的のUIを画面ごとに直書きで複製しない

## Accessibility Baseline

- アイコンのみ操作部品は `contentDescription` を必須とする
- 単一選択UIは `selected` と状態文言を必須とする
- 省略表示時に意味が失われる場合は補助説明を追加する
- タップ可能領域は最小サイズを確保する（48dp目安）

## Acceptance Criteria

- 検索入力と一般入力が視覚的に明確に分離されている
- 単一選択UIが共通コンポーネントで統一されている
- リスト画面のカード過多が解消されている
- 既存挙動（検索、保存、遷移、選択）に回帰がない

## Update Policy

- この方針から逸脱する実装を行う場合、PR説明に理由を明記する
- 段階導入リファクタリングの進行状況は `task.md` に記録する
  - 各フェーズの着手/実装完了/テスト完了/ブロッカーを必ず追記する
  - `Verification` 未記載のフェーズを `Done` にしない
- 新規 `Aero*` コンポーネント追加時は以下を必ず記載する
  - 適用対象
  - 非適用対象
  - 既存コンポーネントとの差分
  - 移行方針（必要な場合）
- UI実装の優先順位（必須）
  1. 既存 `Aero*` をそのまま利用する
  2. 既存 `Aero*` を後方互換で拡張する
  3. それでも満たせない場合のみ新規コンポーネントを追加する
- `Material3` の直書きUI（`TextField`, `Button`, `ModalBottomSheet` など）は、
  共通化対象であれば `Aero*` へ置換することを原則とする
- 直書きUIを残す場合は、PRに「共通化しない理由」を明記する

## Design Compliance Check

- PR作成時に以下を必須チェックとする
  - `AeroSearchField` と `AeroTextInput` の用途混在がない
  - 単一選択UIに `AeroSingleChoiceOptionRow` または同等セマンティクスが適用されている
  - アイコン操作に `contentDescription` が設定されている
  - 新規UIで `Aero*` 再利用を優先し、直書きを追加した場合は理由が記載されている
- 準拠確認コマンド（最低実行）
  - `:app:compileDebugKotlin`
  - `:app:compileDebugAndroidTestKotlin`
  - `:app:testDebugUnitTest`
- UI変更を含む場合は、対象の `androidTest` かスクリーンショット確認結果をPR本文へ記載する
