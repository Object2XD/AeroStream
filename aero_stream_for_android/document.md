# COMPLETE STRUCTURE DIAGRAM (FINAL)

## Quick Return Header の要点

Quick return header（AppBar + Chips + Sort を1ユニットとして扱う）は、
「同時に動く（SIMULTANEOUS）」体感を維持するために以下を満たします。

- Header と Content は同時に動く（スクロールを奪わない）
- `NestedScrollConnection` で `headerOffset` を更新しつつ `consumed=0` を返す
- Header は Content 上にオーバーレイする（`Scaffold topBar` は使わない）
- Content の top padding は `visibleHeaderHeight` で動的制御する
- BottomCard は Section 構造を持つ `ModalBottomSheet` オーバーレイとして扱う
- Insets / Scaffold / Overlay は Root に集約する

---

## Architecture Diagram

```text
AppRoot
└─ RootShell
   ├─ Controllers / State (Single Source of Truth)
   │   ├─ NavState
   │   │   ├─ currentRoute: {Top, Library, AlbumDetail, Search, Settings, SmbBrowser}
   │   │   └─ navigate(route)
   │   │
   │   ├─ ChromeState (route → chrome specs)
   │   │   ├─ headerSpec
   │   │   │   ├─ enabled: true
   │   │   │   ├─ patternName: "Quick return header"
   │   │   │   ├─ title: "Top" | "Library"
   │   │   │   ├─ actions: [Search, Settings]
   │   │   │   └─ accessoryStackSpec (route依存)
   │   │   │       ├─ (Top)     : none
   │   │   │       └─ (Library) : [CategoryChipsSpec, SortRowSpec]
   │   │   ├─ bottomNavSpec
   │   │   │   ├─ visible:
   │   │   │   │   ├─ false when Settings (NonPrimary)
   │   │   │   │   └─ true for Top/Library/AlbumDetail/Search + SmbBrowser(temporary)
   │   │   │   ├─ selected:
   │   │   │   │   ├─ TopRoute -> Top
   │   │   │   │   └─ Library/AlbumDetail/SmbBrowser -> Library (Searchはnull)
   │   │   │   └─ items: [Top, Library]
   │   │   └─ events
   │   │       └─ onBottomNavClick(Library)
   │   │           ├─ if currentRoute != Library → navigate(Library)
   │   │           └─ else (reselect) → OverlayController.open(LibrarySourcePicker)
   │   │
   │   ├─ OverlayState / OverlayController (single-flight)
   │   │   ├─ activeOverlay: None | LibrarySourcePicker | LibrarySortPicker
   │   │   ├─ open(type): if activeOverlay==type then NO-OP
   │   │   ├─ close()
   │   │   └─ confirm(payload) → dispatch to FeatureState
   │   │
   │   ├─ QuickReturnHeaderCoordinator (CUSTOM scroll)  ★CORE
   │   │   ├─ HeaderHeightModel (measured, px only)
   │   │   │   └─ totalHeaderHeightPx = H                       // AppBar + Accessory合計
   │   │   ├─ HeaderOffsetModel (px only)
   │   │   │   └─ headerOffsetPx ∈ [-H, 0]                      // 0=shown, -H=hidden
   │   │   ├─ VisibleHeaderHeightModel (derived)
   │   │   │   └─ visibleHeaderHeightPx = H + headerOffsetPx     // [0..H]
   │   │   ├─ NestedScrollConnection (custom, SIMULTANEOUS policy)
   │   │   │   ├─ onPreScroll(deltaY):
   │   │   │   │   - headerOffsetPx = clamp(headerOffsetPx + deltaY, -H, 0)
   │   │   │   │   - return consumedY = 0   ★IMPORTANT: content also scrolls fully
   │   │   │   ├─ onPostScroll(deltaY):
   │   │   │   │   - (optional) apply same clamp if you want follow-up correction
   │   │   │   │   - return consumedY = 0
   │   │   │   └─ onPreFling/onPostFling:
   │   │   │       - default: no snap (keep as-is) OR
   │   │   │       - optional: weak snap to 0 or -H after fling end
   │   │   ├─ nestedScrollModifier
   │   │   │   └─ if OverlayState.activeOverlay != None → Modifier (disabled)
   │   │   │      else nestedScroll(customConnection)
   │   │   └─ RouteChangeHandler
   │   │       ├─ re-measure H
   │   │       └─ clamp headerOffsetPx into new range [-H,0]
   │   │
   │   └─ FeatureState
   │       ├─ TopState
   │       ├─ LibraryState
   │           ├─ source: {LocalFiles | SMB | Cache}
   │           ├─ category: {Albums | AlbumArtists | Artists | Genres | Years}
   │           ├─ sort: { key:{Name|AddedDate|LastPlayed|Year}, order:{Asc|Desc} }
   │           └─ in-content search: none (use global SearchRoute only)
   │       └─ SearchState
   │           ├─ query: String
   │           ├─ recentSearches: DataStore(max=10, dedupe)
   │           ├─ results: Song[]
   │           └─ searchBarUi:
   │               ├─ filled pill (no outline)
   │               └─ placeholder/input are single-line with ellipsis
   │
   ├─ InsetsHost (ONLY place handling system insets)
   │   └─ Box( Modifier.windowInsetsPadding(WindowInsets.safeDrawing) )
   │      └─ BaseOpaqueLayer( fillMaxSize + background ) // always opaque
   │
   ├─ RootScaffold (ONLY scaffold; NO topBar used)
   │   └─ Scaffold(
   │         contentWindowInsets = WindowInsets(0),
   │         modifier = QuickReturnHeaderCoordinator.nestedScrollModifier,
   │         bottomBar = {
   │           MiniPlayer(...)
   │           if (bottomNavSpec.visible) AppBottomNav(bottomNavSpec.items)
   │         }
   │       ) { innerPadding ->
   │
   │       └─ ChromeLayoutHost (Box layering for header overlay + content)
   │           └─ Box( Modifier.fillMaxSize().padding(innerPadding) )
   │               ├─ ContentLayer  ★KEY: dynamic top padding
   │               │   └─ Box(
   │               │        Modifier
   │               │          .fillMaxSize()
   │               │          .padding(top = visibleHeaderHeightDp)     // px→dp変換した値
   │               │      )
   │               │      └─ NavHost
   │               │          ├─ TopRoute
   │               │          │   └─ TopScreenContent (Insets禁止)
   │               │          │       └─ PrimaryVerticalScrollContainer (single vertical)
   │               │          ├─ LibraryRoute
   │               │              └─ LibraryScreenContent (Insets禁止)
   │               │                  └─ PrimaryVerticalScrollContainer (single vertical)
   │               │          ├─ AlbumDetailRoute (Primary扱い)
   │               │          │   └─ hero artwork: fixed 300dp max, clamped by available width, centered
   │               │          ├─ SearchRoute (NonPrimary, BottomNav visible)
   │               │          ├─ SettingsRoute (NonPrimary)
   │               │          └─ SmbBrowserRoute (temporary: BottomNav visible)
   │               │
   │               └─ HeaderOverlayLayer  ★KEY: header moves but does not steal scroll
   │                   └─ QuickReturnHeaderContainer (ONE moving unit)
   │                       ├─ clipToBounds(), zIndex(foreground)
   │                       ├─ apply translation:
   │                       │    Modifier.offset { IntOffset(0, headerOffsetPx.roundToInt()) }
   │                       ├─ HeaderHeightMeasure (diff-guarded)
   │                       │    - measures this container’s total heightPx (H)
   │                       │    - updates H only if changed (±1px ignore recommended)
   │                       ├─ TopAppBarRow (pinned)
   │                       │   └─ TopAppBar(
   │                       │        windowInsets = WindowInsets(0),
   │                       │      )
   │                       │      ├─ title: "Top" | "Library"
   │                       │      └─ actions: IconButton(Search), IconButton(Settings)
   │                       └─ HeaderAccessoryStackSlot (route依存)
   │                           ├─ (Top)     : none
   │                           └─ (Library) : Column
   │                               ├─ CategoryChipsRow
   │                               │   ├─ Chips: Albums / Album Artists / Artists / Genres / Years
   │                               │   └─ onSelect(cat) → LibraryState.category = cat
   │                               └─ SortRow
   │                                   ├─ Label: "Sort: {key} / {order}"
   │                                   └─ Button: "Change"
   │                                       └─ onClick → OverlayController.open(LibrarySortPicker)
   │
   └─ OverlayHost (ONLY place showing overlays)
       └─ BottomCardRouter(activeOverlay)
           ├─ (None) : nothing
           ├─ LibrarySourcePickerBottomCard (ModalBottomSheet = overlay)
           │   └─ BottomCard (Sections)
           │       ├─ Header: "Library source"
           │       └─ Section: "Source" (single select, required)
           │           ├─ Local files
           │           ├─ SMB
           │           └─ Cache
           │       └─ onConfirm(selection) → LibraryState.source = selection; close()
           └─ LibrarySortPickerBottomCard (ModalBottomSheet = overlay)
               └─ BottomCard (Sections)
                   ├─ Header: "Sort options"
                   ├─ Section: "Sort"  (single select, required)
                   │   ├─ Name
                   │   ├─ Added date
                   │   ├─ Last played
                   │   └─ Year
                   ├─ Section: "Order" (single select, required)
                   │   ├─ Ascending
                   │   └─ Descending
                   └─ onConfirm(key, order) → LibraryState.sort = (key, order); close()
```

---

## CAUTIONS / RULES

### R1. Insets: Root only
- Root以外の `statusBarsPadding/systemBarsPadding/windowInsetsPadding` を禁止
- `TopAppBar/NavigationBar` は `windowInsets = WindowInsets(0)` 固定（共通コンポーネント経由のみ）
- 各画面 `Scaffold` は `contentWindowInsets = WindowInsets(0)` を明示（Rootとの二重Insets禁止）
- `AlbumDetailScreen` は画面内 `Scaffold` を持たず、Rootの `InsetsHost + RootScaffold(innerPadding)` に完全追従する

### R2. Header overlay + dynamic content padding
- HeaderはContent上に重ねる（Scaffold topBar不使用）
- Contentのtop paddingは `visibleHeaderHeight`（dp変換）で動的制御（空白/潜り防止）

### R3. “Simultaneous” policy = do NOT consume scroll
- `NestedScrollConnection` は `headerOffsetPx` を更新するが `consumed=0` を返す
- ヘッダとコンテンツが同じドラッグで同時に動く（スクロールを奪わない）

### R4. Measurement stability
- `HeaderHeightMeasure` は差分がある場合のみ更新（±1px無視推奨）
- 多言語/フォントスケールで高さが変わる前提（固定dp禁止）

### R5. One primary vertical scroll
- Header連動対象の縦スクロールは1本に限定（ネスト縦スクロール禁止）

R6. Overlay behavior
- BottomCard(ModalBottomSheet)はOverlayHostのみ、single-flight、Back最優先
- Overlay表示中は nestedScroll を無効化して体感を安定化

R6.5 AlbumDetail hero sizing
- hero artwork は固定300dp上限で描画し、端末の利用可能幅を超える場合のみクランプする
- artwork本体の `Modifier` に `fillMaxWidth` を使わない（幅確定を壊さない）
- artwork は常に中央配置する

R6.6 AlbumDetail bottom play shortcut spacing
- `albumDetailBottomPlayTopPadding` は footer summary と再生ボタンの距離のみを制御する
- `albumDetailBottomPlayBottomClearance` は再生ボタンと下部UI（MiniPlayer/BottomNav）間のクリアランスを制御する
- `albumDetailListBottomPadding` は LazyColumn 全体の末尾余白を制御する（既定値は 0dp）
- 再生ボタンの下位置調整は `albumDetailBottomPlayBottomClearance` を使用し、`contentPadding.bottom` に依存させない

R7. SystemBar color ownership (edge-to-edge)
- enableEdgeToEdge は維持する
- SystemBar制御の責務は MainActivity（enableEdgeToEdge + SystemBarStyle）に限定する
- `SystemBarStyle.auto` は使用しない（light/dark を明示指定）
- Theme からの Window 直接制御（status/navigationBarColor, InsetsController）は禁止
- Insetsの適用責務はRoot（WindowInsets.safeDrawing のみ）に限定する
- Root は常時不透明の基底面（BaseOpaqueLayer）を持つ
- 外側領域の描画責務は子（Header/BottomNav 連動レイヤー）に持たせる
- 実装は「拡張+オフセット」: status/navigation bar分だけ子レイヤーを外へ伸ばして描画する
- EdgeBackdrop のトーンは route で決定し、Settings は top/bottom とも background に統一する
- values/themes.xml 側での transparent 指定を禁止（Runtime設定との二重管理禁止）
