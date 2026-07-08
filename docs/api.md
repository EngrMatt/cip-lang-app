# Field Language API 文件

田野語料收集平台後端 API 規格。Web 管理後台（`cip-lang-web`）與 Flutter App（`cip-lang-app`）共用同一組 API。

| 項目 | 說明 |
|------|------|
| Base URL（測試環境） | `https://cip-lang-test-20260624.nfs.tw` |
| Base URL（本地） | `http://localhost:8280` |
| 互動文件（Swagger） | https://cip-lang-test-20260624.nfs.tw/docs |
| 認證 | MVP 階段無需認證 |
| 資料格式 | JSON（上傳端點為 `multipart/form-data`） |

### 客戶端與端點對照

| 端點 | Web Admin | Flutter App |
|------|:---------:|:-----------:|
| `GET /health` | — | 選用 |
| `GET /records/stats` | ✅ | — |
| `GET /records` | ✅ | ✅ |
| `GET /records/map` | — | ✅ |
| `POST /records` | — | ✅ |
| `GET /records/{id}` | ✅ | ✅ |
| `PUT /records/{id}` | ✅ | ✅（上傳後更新 URL） |
| `DELETE /records/{id}` | ✅ | ✅ |
| `POST /upload/audio` | — | ✅ |
| `POST /upload/image` | — | ✅ |

---

## 通用說明

### 請求標頭

JSON 端點：

```http
Content-Type: application/json
```

上傳端點：

```http
Content-Type: multipart/form-data
```

### 錯誤回應

FastAPI 標準格式：

```json
{
  "detail": "錯誤訊息"
}
```

驗證錯誤（422）時 `detail` 為陣列，見各端點說明。

| HTTP 狀態碼 | 說明 |
|-------------|------|
| 201 | 資源建立成功 |
| 400 | 請求無效（檔案類型、大小等） |
| 404 | 資源不存在 |
| 422 | JSON body 驗證失敗 |
| 500 | 伺服器錯誤（含 S3 未設定或上傳失敗） |

---

## 資料模型

### Record（語料）

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `id` | integer | — | 主鍵（自動產生） |
| `title` | string | ✅ | 標題，1–255 字元 |
| `category` | string | ✅ | 類型，預設 `未分類`，最長 100 字元 |
| `note` | string \| null | — | 備註 |
| `audio_url` | string \| null | — | 錄音公開 URL（S3） |
| `image_url` | string \| null | — | 照片公開 URL（S3） |
| `latitude` | number \| null | — | 緯度（WGS84，-90 ~ 90） |
| `longitude` | number \| null | — | 經度（WGS84，-180 ~ 180） |
| `created_at` | datetime (ISO 8601) | — | 建立時間（UTC） |

### 範例

```json
{
  "id": 1,
  "title": "阿美語問候語錄音",
  "category": "錄音",
  "note": "採集於花蓮部落，品質良好",
  "audio_url": "https://your-bucket.s3.ap-northeast-1.amazonaws.com/audio/1/abc123.m4a",
  "image_url": "https://your-bucket.s3.ap-northeast-1.amazonaws.com/images/1/def456.jpg",
  "latitude": 22.6273,
  "longitude": 120.3014,
  "created_at": "2026-06-23T07:39:18.422000Z"
}
```

---

## 端點一覽

| 方法 | 路徑 | 說明 |
|------|------|------|
| GET | `/health` | 健康檢查 |
| GET | `/records/stats` | Dashboard 統計 |
| GET | `/records` | 語料列表（分頁、搜尋、篩選） |
| GET | `/records/map` | 地圖採集點（僅有座標的紀錄） |
| POST | `/records` | 新增語料 |
| GET | `/records/{id}` | 單筆語料詳細 |
| PUT | `/records/{id}` | 更新語料 |
| DELETE | `/records/{id}` | 刪除語料 |
| POST | `/upload/audio` | 上傳錄音至 S3 |
| POST | `/upload/image` | 上傳照片至 S3 |

---

## GET /health

服務健康檢查。

**回應 200**

```json
{
  "status": "ok"
}
```

---

## GET /records/stats

取得 Dashboard 統計資料（Web Admin 專用）。

**回應 200**

```json
{
  "total": 4,
  "monthly_new": 2,
  "recent": [
    {
      "id": 1,
      "title": "阿美語問候語錄音",
      "category": "錄音",
      "note": "採集於花蓮部落，品質良好",
      "audio_url": "https://your-bucket.s3.ap-northeast-1.amazonaws.com/audio/1/abc123.m4a",
      "image_url": "https://your-bucket.s3.ap-northeast-1.amazonaws.com/images/1/def456.jpg",
      "created_at": "2026-06-23T07:39:18.422000Z"
    }
  ]
}
```

| 欄位 | 說明 |
|------|------|
| `total` | 語料總筆數 |
| `monthly_new` | 當月新增筆數（UTC 月初起算） |
| `recent` | 最近 5 筆（依 `created_at` 降序） |

---

## GET /records

取得語料列表，支援分頁、關鍵字搜尋與類型篩選。

### Query 參數

| 參數 | 類型 | 預設 | 說明 |
|------|------|------|------|
| `page` | integer | `1` | 頁碼（≥ 1） |
| `page_size` | integer | `10` | 每頁筆數（1–100） |
| `search` | string | — | 比對 `title`、`note`（不分大小寫） |
| `category` | string | — | 依類型精確篩選 |

### 範例

```http
GET /records?page=1&page_size=10&search=阿美&category=錄音
```

### 回應 200

```json
{
  "items": [
    {
      "id": 1,
      "title": "阿美語問候語錄音",
      "category": "錄音",
      "note": "採集於花蓮部落，品質良好",
      "audio_url": "https://your-bucket.s3.ap-northeast-1.amazonaws.com/audio/1/abc123.m4a",
      "image_url": "https://your-bucket.s3.ap-northeast-1.amazonaws.com/images/1/def456.jpg",
      "created_at": "2026-06-23T07:39:18.422000Z"
    }
  ],
  "total": 1,
  "page": 1,
  "page_size": 10
}
```

---

## POST /records

建立新語料（Flutter App 上傳流程第一步）。

### Request Body

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `title` | string | ✅ | 標題，1–255 字元 |
| `category` | string | — | 類型，預設 `未分類` |
| `note` | string \| null | — | 備註 |
| `latitude` | number \| null | — | 緯度（須與 longitude 同時有值或同時為 null） |
| `longitude` | number \| null | — | 經度 |

### 範例請求

```http
POST /records
Content-Type: application/json

{
  "title": "阿美語問候語錄音",
  "category": "錄音",
  "note": "採集於花蓮部落",
  "latitude": 23.9739,
  "longitude": 121.6015
}
```

### 回應 201

```json
{
  "id": 5,
  "title": "阿美語問候語錄音",
  "category": "錄音",
  "note": "採集於花蓮部落",
  "audio_url": null,
  "image_url": null,
  "latitude": 23.9739,
  "longitude": 121.6015,
  "created_at": "2026-06-24T08:00:00.000000Z"
}
```

### 回應 422

`title` 為空或格式錯誤時回傳驗證錯誤。只傳 `latitude` 或只傳 `longitude`、或座標超出合法範圍時亦回傳 422。

---

## GET /records/map

取得**有 GPS 座標**的語料，供地圖 marker 使用。不回傳 `latitude` / `longitude` 為 null 的紀錄。

### Query 參數

| 參數 | 類型 | 預設 | 說明 |
|------|------|------|------|
| `bbox` | string | — | 選填。`min_lng,min_lat,max_lng,max_lat`（WGS84） |
| `category` | string | — | 依類型精確篩選 |
| `limit` | integer | `500` | 單次回傳上限（建議 100–1000） |

### 範例

```http
GET /records/map?bbox=121.0,23.0,122.0,24.5&limit=500
```

### 回應 200

```json
{
  "items": [
    {
      "id": 8,
      "title": "排灣語田野筆記",
      "category": "錄音",
      "note": "部落入口訪談",
      "audio_url": "https://your-bucket.s3.amazonaws.com/audio/8/abc.m4a",
      "image_url": null,
      "latitude": 22.6273,
      "longitude": 120.3014,
      "created_at": "2026-07-03T07:06:21.266947Z"
    }
  ],
  "total": 1
}
```

> 與 `GET /records` 不同，此端點不回傳 `page` / `page_size`。

---

## GET /records/{id}

取得單筆語料。

### Path 參數

| 參數 | 類型 | 說明 |
|------|------|------|
| `id` | integer | 語料 ID |

### 回應 200

完整 Record 物件。

### 回應 404

```json
{
  "detail": "語料不存在"
}
```

---

## PUT /records/{id}

更新語料（partial update，僅傳要修改的欄位）。

### Request Body

| 欄位 | 類型 | 說明 |
|------|------|------|
| `title` | string | 標題，1–255 字元 |
| `category` | string | 類型 |
| `note` | string \| null | 備註 |
| `audio_url` | string \| null | 錄音 URL |
| `image_url` | string \| null | 照片 URL |
| `latitude` | number \| null | 緯度 |
| `longitude` | number \| null | 經度 |

### 範例

```http
PUT /records/1
Content-Type: application/json

{
  "title": "阿美語問候語錄音（修訂）",
  "note": "已重新檢查音質"
}
```

### 回應 200

更新後的完整 Record 物件。

### 回應 404 / 422

語料不存在或欄位驗證失敗。

---

## DELETE /records/{id}

刪除語料。

### 回應 204

無 body。

### 回應 404

```json
{
  "detail": "語料不存在"
}
```

---

## POST /upload/audio

上傳錄音至 AWS S3，並將回傳 URL 寫入 `records.audio_url`。

**前置條件：** `.env` 已設定 AWS 憑證與 `S3_BUCKET_NAME`。

### Request（multipart/form-data）

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `record_id` | integer | ✅ | 語料 ID（須已存在） |
| `file` | file | ✅ | 錄音檔 |

| 限制 | 值 |
|------|-----|
| 允許副檔名 | `.m4a`、`.mp3`、`.wav`、`.aac` |
| 大小上限 | 50 MB |

S3 object key 格式：`audio/{record_id}/{uuid}.{ext}`

### 範例

```bash
curl -X POST http://localhost:8280/upload/audio \
  -F "record_id=5" \
  -F "file=@recording.m4a"
```

### 回應 200

```json
{
  "audio_url": "https://your-bucket.s3.ap-northeast-1.amazonaws.com/audio/5/a1b2c3d4.m4a"
}
```

### 錯誤

| 狀態碼 | 情境 |
|--------|------|
| 400 | 檔名缺失、檔案為空、類型不支援、超過大小上限 |
| 404 | `record_id` 不存在 |
| 500 | S3 未設定或 `PutObject` 失敗 |

---

## POST /upload/image

上傳照片至 AWS S3，並將回傳 URL 寫入 `records.image_url`。

### Request（multipart/form-data）

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `record_id` | integer | ✅ | 語料 ID |
| `file` | file | ✅ | 照片檔 |

| 限制 | 值 |
|------|-----|
| 允許副檔名 | `.jpg`、`.jpeg`、`.png`、`.webp` |
| 大小上限 | 10 MB |

S3 object key 格式：`images/{record_id}/{uuid}.{ext}`

### 範例

```bash
curl -X POST http://localhost:8280/upload/image \
  -F "record_id=5" \
  -F "file=@photo.jpg"
```

### 回應 200

```json
{
  "image_url": "https://your-bucket.s3.ap-northeast-1.amazonaws.com/images/5/e5f6g7h8.jpg"
}
```

錯誤碼同 `POST /upload/audio`。

---

## Flutter App 上傳流程

`cip-lang-app` 完整上傳順序：

```
POST /records          → 取得 id
POST /upload/audio     → 上傳錄音（必填）
POST /upload/image     → 上傳照片（選填）
PUT /records/{id}      → 更新 URL（冗餘，上傳端點已寫入 DB）
```

### Base URL 設定

| 環境 | Base URL |
|------|----------|
| **測試環境（App 預設）** | `https://cip-lang-test-20260624.nfs.tw` |
| Android 模擬器（本地） | `http://10.0.2.2:8280` |
| iOS 模擬器（本地） | `http://localhost:8280` |
| 實機（本地） | `http://<開發機 LAN IP>:8280` |

App MVP 規格見 [flutter-mvp.md](./flutter-mvp.md)。

---

## Web 前端 Proxy

React 開發環境（http://localhost:3202）透過 Vite proxy 轉發：

| 前端路徑 | 轉發至 |
|----------|--------|
| `/records` | `VITE_API_PROXY_TARGET`（Docker 內為 `http://api:8280`） |
| `/health` | 同上 |

上傳端點由 Flutter 直連 API，不經 Web proxy。

---

## 環境變數

| 變數 | 說明 | 預設 |
|------|------|------|
| `DATABASE_URL` | PostgreSQL 連線字串 | 見 `.env.example` |
| `API_PORT` | API 對外 port | `8280` |
| `WEB_PORT` | 前端對外 port | `3202` |
| `CORS_ORIGINS` | 允許的前端來源（逗號分隔） | `http://localhost:3202` |
| `AWS_ACCESS_KEY_ID` | AWS 存取金鑰 | — |
| `AWS_SECRET_ACCESS_KEY` | AWS 秘密金鑰 | — |
| `AWS_REGION` | S3 區域 | `ap-northeast-1` |
| `S3_BUCKET_NAME` | 媒體 bucket 名稱 | — |
| `S3_PUBLIC_URL_PREFIX` | 公開 URL 前綴（選填） | — |

### AWS / S3 設定說明

**必填（上傳功能）：** `AWS_ACCESS_KEY_ID`、`AWS_SECRET_ACCESS_KEY`、`S3_BUCKET_NAME`

**`S3_PUBLIC_URL_PREFIX`（選填）：**

- 未設定：回傳 `https://{bucket}.s3.{region}.amazonaws.com/{key}`
- 已設定（如 CloudFront）：回傳 `{prefix}/{key}`

**IAM 權限：** 目標 bucket 需 `s3:PutObject`

**媒體讀取：** Web / App 播放錄音、顯示照片需 bucket 公開讀或透過 CloudFront；建議 bucket CORS 允許 `GET` from `http://localhost:3202`
