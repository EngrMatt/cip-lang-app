## Why

田野語料採集需記錄 GPS 座標，並在地圖上瀏覽採集點。後端已支援 `latitude`/`longitude` 與 `GET /records/map`，App 需串接並完成地圖互動。

## What Changes

- 新增語料時讀取 GPS，於 `POST /records` 帶入座標（失敗時允許 null）
- 地圖頁呼叫 `GET /records/map`，依可視 bbox 顯示 marker
- 點 marker 顯示底部語料圖卡，可進入詳細頁
- 定位按鈕移至使用者目前位置
- iOS/Android 定位權限宣告
- 更新 `docs/api.md` 與 Record 模型

## Capabilities

### New Capabilities

- `map-explore`：地圖採集點 marker、圖卡與定位

### Modified Capabilities

- `record-create`：上傳時附帶 GPS 座標

## Non-goals

- 舊資料補登座標
- Marker 叢集
- 離線地圖快取
