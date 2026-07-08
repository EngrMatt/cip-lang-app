# map-explore

## Purpose

地圖分頁：顯示有 GPS 的語料採集點、圖卡摘要與定位。

## Requirements

### Requirement: 地圖採集點顯示

系統 SHALL 於地圖分頁以 OpenStreetMap 底圖顯示有 GPS 座標的語料採集點。

#### Scenario: 載入採集點

- **WHEN** 使用者進入地圖分頁
- **THEN** 系統呼叫 `GET /records/map` 並於對應座標顯示 marker

#### Scenario: 隨地圖移動更新

- **WHEN** 使用者拖曳或縮放地圖
- **THEN** 系統以目前可視範圍 bbox 重新請求採集點

### Requirement: 採集點圖卡

系統 SHALL 於使用者點擊 marker 時顯示語料摘要圖卡。

#### Scenario: 顯示圖卡

- **WHEN** 使用者點擊某 marker
- **THEN** 系統顯示標題、類型、時間、備註摘要與縮圖（若有照片）

#### Scenario: 進入詳細頁

- **WHEN** 使用者點擊圖卡「查看詳細」
- **THEN** 系統導向該語料詳細頁

### Requirement: 定位至目前位置

系統 SHALL 提供按鈕將地圖移至使用者目前 GPS 位置。

#### Scenario: 定位成功

- **WHEN** 使用者點擊定位按鈕且已取得權限
- **THEN** 地圖移至目前位置並適當縮放

#### Scenario: 定位失敗

- **WHEN** 無法取得 GPS 或權限遭拒
- **THEN** 系統顯示提示，不阻斷地圖瀏覽
