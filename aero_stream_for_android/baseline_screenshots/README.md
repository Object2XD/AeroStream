# Baseline Screenshots (Phase 0)

Phase 0 の比較基準として、以下の5画面を固定する。

## Canonical Files

1. `01_library.png`  
   - Library 画面（ルート）
2. `02_search.png`  
   - Search 画面
3. `03_settings.png`  
   - Settings 画面
4. `04_smb_browser.png`  
   - SMB Browser 画面
5. `05_album_detail_na.png`  
   - AlbumDetail は実データ不足により遷移不可のため、当面 `N/A` 記録

## Notes

- `05_album_detail_na.png` は「AlbumDetail が現環境で取得不能」であることを示す暫定基準。  
- AlbumDetail 遷移可能なデータが用意でき次第、`05_album_detail.png` を再取得して差し替える。
- 本フォルダ内の他ファイル（`tmp_*` 等）は作業途中の取得物であり、比較基準には使用しない。

## Design.md Baseline Checklist

- 入力UIは検索用と一般入力用で分離されている（`AeroSearchField` / `AeroTextInput`）
- 単一選択UIは共通化されている（`AeroSingleChoiceOptionRow`）
- 主要操作の `contentDescription` が設定されている
- 画面ごとの過剰カード化がない
