# 後端 API 需求：地圖採集點與語料圖卡

> **提出方**：`cip-lang-app`（Flutter）  
> **對象**：`cip-lang-web` / FastAPI 後端  
> **版本**：v0.1（2026-07-03）  
> **狀態**：後端已實作（2026-07-03）；App 已串接

---

## 1. 產品目標

App「地圖」分頁需達成：

1. 地圖上顯示**有 GPS 座標的語料採集點**（marker）
2. 使用者**點擊 marker** → 底部或浮層顯示**語料圖卡**（標題、類型、時間、摘要等）
3. 圖卡可進一步進入既有**語料詳細頁**（播放錄音、看照片）

目前 App 已具備：

- OpenStreetMap 底圖（`flutter_map`）
- 語料 CRUD、上傳錄音／照片、詳細頁播放
- **尚無** GPS 採集與地圖 marker 資料來源

---

## 2. 使用者流程（App 端預期）

```
新增語料（wizard）
  → 手機讀取 GPS（採集當下）
  → POST /records（含 latitude, longitude）
  → 上傳錄音 / 照片
  → 完成

地圖頁
  → GET /records/map（或帶 bbox 的 GET /records）
  → 畫 marker
  → 點 marker → 顯示圖卡（列表摘要欄位即可）
  → 點「查看詳細」→ GET /records/{id}（既有）
```

---

## 3. 既有 API 缺口評估

| 項目 | 現況 | 地圖功能是否足夠 |
|------|------|------------------|
| `Record` 含 `latitude` / `longitude` | ❌ 無 | **不足** — 無法標記位置 |
| `POST /records` 接受座標 | ❌ 無 | **不足** — 採集時無法寫入 |
| `PUT /records/{id}` 更新座標 | ❌ 無 | 建議有（補登舊資料） |
| `GET /records` 回傳座標 | ❌ 無 | **不足** |
| 依地圖範圍篩選（bbox） | ❌ 無 | **建議有** — 資料多時必要 |
| 只回有座標的紀錄 | ❌ 無 | **建議有** — 地圖不需 null 點 |
| `GET /records/{id}` 詳細 | ✅ 有 | **足夠** — 圖卡點進詳情可用 |
| `audio_url` / `image_url` | ✅ 有 | **足夠** — 圖卡可顯示縮圖 |
| S3 公開讀取 | ✅ 已設定 | **足夠** |

**結論**：不必重做整套 API，但 **`Record` 必須新增經緯度欄位**，並擴充 **建立／查詢** 端點。建議另提供 **地圖專用輕量列表**，避免一次拉全庫。

---

## 4. 需求優先級

### P0（沒有就做不了地圖）

1. 資料庫與 `Record` 模型新增 `latitude`、`longitude`（可為 `null`）
2. `POST /records`、`PUT /records/{id}` 接受並驗證座標
3. 所有回傳 `Record` 的 GET 端點一併帶出座標欄位
4. 新增 **`GET /records/map`**（或等效查詢參數）— 只回有座標的紀錄 + 地圖所需摘要欄位

### P1（建議，體驗與效能）

5. `GET /records/map` 支援 **bounding box**（地圖可視範圍）
6. `has_location=true` 查詢參數（若沿用 `GET /records`）
7. 舊資料 migration：`latitude` / `longitude` 預設 `NULL`（地圖不顯示）

### P2（未來）

8. 叢集（cluster）由後端預先聚合 — 資料量 > 數千筆再考慮
9. `accuracy`（GPS 精度米）、`captured_at`（採集時間 ≠ `created_at`）

---

## 5. 資料模型變更

### 5.1 `records` 表新增欄位

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `latitude` | `float` / `DECIMAL(9,6)` | 否 | 緯度，WGS84，範圍 **-90 ~ 90** |
| `longitude` | `float` / `DECIMAL(9,6)` | 否 | 經度，WGS84，範圍 **-180 ~ 180** |

**規則**：

- `latitude` 與 `longitude` **必須同時有值或同時為 `null`**（不可只填一個）
- 建立時若 App 未取得 GPS（權限拒絕、室內失敗），允許 `null` — 該筆不顯示於地圖
- 既有紀錄維持 `null`，不強制補填

### 5.2 Record JSON 範例（擴充後）

```json
{
  "id": 8,
  "title": "測試",
  "category": "錄音",
  "note": "[調查員: 陳建名 | 鳳山區] 此惡測試",
  "audio_url": "https://cip-lang-bucket.s3.us-east-1.amazonaws.com/audio/8/xxx.m4a",
  "image_url": "https://cip-lang-bucket.s3.us-east-1.amazonaws.com/images/8/xxx.jpg",
  "latitude": 22.6273,
  "longitude": 120.3014,
  "created_at": "2026-07-03T15:06:21.266947+08:00"
}
```

---

## 6. 端點變更規格

### 6.1 `POST /records`（修改）

**Request Body 新增**：

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `latitude` | number \| null | 否 | 緯度 |
| `longitude` | number \| null | 否 | 經度 |

**範例**：

```json
{
  "title": "排灣語田野筆記",
  "category": "錄音",
  "note": "部落入口訪談",
  "latitude": 22.123456,
  "longitude": 120.654321
}
```

**驗證（422）**：

- 只傳 `latitude` 或只傳 `longitude` → 錯誤
- 超出合法範圍 → 錯誤
- 非數字 → 錯誤

---

### 6.2 `PUT /records/{id}`（修改）

同上，允許事後補填或修正座標：

```json
{
  "latitude": 22.123456,
  "longitude": 120.654321
}
```

---

### 6.3 `GET /records`、`GET /records/{id}`（修改）

回應中的每筆 `Record` **必須包含** `latitude`、`longitude`（可為 `null`）。

**可選 Query 參數（若不想開新端點）**：

| 參數 | 說明 |
|------|------|
| `has_location` | `true` 時只回 `latitude` / `longitude` 皆非 null 的紀錄 |
| `bbox` | `min_lng,min_lat,max_lng,max_lat`（地圖可視範圍） |

> 若採用此方式，仍建議回應欄位與下方 `GET /records/map` 一致時可做輕量化。

---

### 6.4 `GET /records/map`（**建議新增，P0**）

專供地圖 marker 使用，**不回傳無座標紀錄**，payload 精簡。

#### Query 參數

| 參數 | 類型 | 預設 | 說明 |
|------|------|------|------|
| `bbox` | string | — | 選填。`min_lng,min_lat,max_lng,max_lat`（WGS84） |
| `category` | string | — | 選填。類型篩選 |
| `limit` | integer | `500` | 單次上限（建議 100–1000） |

#### 回應 200

```json
{
  "items": [
    {
      "id": 8,
      "title": "測試",
      "category": "錄音",
      "note": "[調查員: 陳建名 | 鳳山區] 此惡測試",
      "latitude": 22.6273,
      "longitude": 120.3014,
      "audio_url": "https://.../audio/8/xxx.m4a",
      "image_url": "https://.../images/8/xxx.jpg",
      "created_at": "2026-07-03T15:06:21.266947+08:00"
    }
  ],
  "total": 1
}
```

#### 圖卡顯示對照（App 端）

| 圖卡元素 | 使用欄位 |
|----------|----------|
| 標題 | `title` |
| 類型標籤 | `category` |
| 時間 | `created_at` |
| 摘要 | `note`（可截斷前 80 字） |
| 縮圖 | `image_url`（無則顯示錄音圖示） |
| 進詳情 | `id` → `GET /records/{id}` |

**不需**為圖卡另開 API；`GET /records/map` 摘要 + 既有 `GET /records/{id}` 即可。

---

## 7. 資料庫 Migration 建議

```sql
ALTER TABLE records
  ADD COLUMN latitude  DECIMAL(9, 6) NULL,
  ADD COLUMN longitude DECIMAL(9, 6) NULL;

-- 可選：僅在兩者皆非 null 時才允許
-- CHECK (
--   (latitude IS NULL AND longitude IS NULL)
--   OR (latitude IS NOT NULL AND longitude IS NOT NULL)
-- );
```

既有資料不受影響（座標為 `NULL`）。

---

## 8. 驗收標準（Acceptance Criteria）

後端完成後，應能通過以下手動測試：

### 8.1 寫入

```bash
curl -X POST "$BASE/records" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "地圖測試點",
    "category": "錄音",
    "note": "GPS 測試",
    "latitude": 23.9739,
    "longitude": 121.6044
  }'
```

→ `201`，回應含 `latitude`、`longitude`

### 8.2 地圖列表

```bash
curl "$BASE/records/map"
```

→ 只含座標非 null 的紀錄；每筆有 `id`, `title`, `category`, `lat`, `lng`

### 8.3 範圍篩選

```bash
curl "$BASE/records/map?bbox=121.0,23.0,122.0,24.5"
```

→ 只回 bbox 內的點

### 8.4 詳細頁

```bash
curl "$BASE/records/{id}"
```

→ 含完整 `audio_url`、`image_url`、座標，供 App 詳情與播放

### 8.5 驗證錯誤

```bash
curl -X POST "$BASE/records" \
  -H "Content-Type: application/json" \
  -d '{"title":"x","category":"錄音","latitude":23.0}'
```

→ `422`（缺 `longitude`）

---

## 9. App 端後續對應（供參考，非後端範圍）

後端 P0 完成後，`cip-lang-app` 將：

1. 採集 wizard：`geolocator` 讀 GPS → `POST /records` 帶座標
2. 地圖頁：`GET /records/map` → `MarkerLayer`
3. 點 marker → 底部 `DraggableScrollableSheet` 圖卡
4. 圖卡「查看詳細」→ 既有 `/records/{id}` 頁

---

## 10. 不建議現階段做的事

| 項目 | 原因 |
|------|------|
| 另開 `/media/proxy` | S3 已公開讀取，App 直接用 URL |
| 圖卡專用 API | 與 `GET /records/map` 重複 |
| 強制每筆必有 GPS | 室內／權限拒絕會阻擋採集 |
| PostGIS 複雜查詢 | 初期筆數少，bbox + index 足夠 |

---

## 11. 相關文件

- 現行 API 規格：[`docs/api.md`](./api.md)
- App MVP：[`docs/mvp.md`](./mvp.md)
- 實作完成後請同步更新 `docs/api.md` 並通知 Flutter 端串接

---

## 12. 最小實作清單（給後端快速開工）

- [ ] DB migration：`latitude`, `longitude`
- [ ] Pydantic / SQLAlchemy 模型更新
- [ ] `POST /records`、`PUT /records/{id}` 支援座標與驗證
- [ ] `GET /records`、`GET /records/{id}` 回傳座標
- [ ] 新增 `GET /records/map`（`has_location` + 可選 `bbox`）
- [ ] Swagger 更新
- [ ] 用 curl 跑完 §8 驗收

**預估工作量**：小～中（若僅 P0，約 0.5–1 天）
