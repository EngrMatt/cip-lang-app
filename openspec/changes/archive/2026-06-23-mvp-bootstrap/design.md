## Context

`cip-lang-app` 是田野語料收集平台的 Flutter 行動端，作為資料**上傳端**。姊妹專案 `cip-lang-web` 已提供 FastAPI 後端與 Web 管理後台。本 change 依 `docs/mvp.md` 從零建立 Flutter MVP，串接既有後端 API。

**現況**：
- 本 repo 為綠地，尚無 Flutter 程式碼
- **純前端**：本 App 僅含 Flutter client，後端 API 規格見 `docs/api.md`
- 後端 `GET /records`、`GET /records/{id}`、`PUT /records/{id}` 已實作
- `POST /records`、`POST /upload/audio`、`POST /upload/image` 尚未實作（見 `docs/api.md`）
- UI 設計稿：`design/field_ethos/DESIGN.md`、`design/record_list/`、`design/new_record_form/`、`design/mobile_record_detail/`

## Goals / Non-Goals

**Goals:**

- `flutter run` 可啟動 App，涵蓋列表、新增、錄音、拍照、上傳、詳細頁
- Riverpod 管理狀態，Dio 呼叫後端 API
- 繁體中文 UI
- iOS / Android 麥克風與相機權限正確宣告

**Non-Goals:**

- 登入與權限（MVP 不含 auth）
- 離線同步與本地持久化佇列
- GPS、AI 功能
- 生產環境部署與 App Store 上架

## Decisions

### 1. 專案結構：Feature-first

**決定**：以 `lib/features/<feature>/` 組織，每個 feature 含 `presentation/`、`providers/`、`widgets/`。

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/app_config.dart      # API base URL
│   └── network/dio_client.dart
├── models/record.dart
└── features/
    ├── records/          # 列表、詳細、新增
    ├── audio/            # 錄音與播放
    └── camera/           # 拍照
```

**理由**：對應 MVP 的 5 個畫面，模組邊界清楚，便於獨立開發與測試。

**替代方案**：Clean Architecture 三層 — MVP 階段過度，暫不採用。

### 2. 狀態管理：Riverpod

**決定**：使用 `flutter_riverpod`，API 呼叫封裝於 `RecordRepository`，由 `AsyncNotifier` / `FutureProvider` 暴露給 UI。

**理由**：`docs/mvp.md` 已指定；Riverpod 與 Flutter 3.x 整合良好，適合 async API 狀態。

### 3. 路由：go_router

**決定**：使用 `go_router` 宣告式路由。

| 路徑 | 頁面 |
|------|------|
| `/` | 語料列表 |
| `/records/new` | 新增語料（多步驟 wizard） |
| `/records/:id` | 語料詳細 |

**理由**：深層連結與型別安全的路由參數；比 Navigator 1.0 更易維護。

### 4. 新增流程：多步驟 Wizard

**決定**：新增語料採單一 wizard 流程：基本資料 → 錄音 → 拍照 → 上傳確認。

**理由**：對應 `docs/mvp.md` 的 Screen 02–04；引導田野調查員依序完成採集。

**狀態**：使用 `StateNotifier` 暫存表單、錄音檔路徑、照片路徑，上傳成功後清除。

### 5. 錄音與播放

**決定**：
- 錄音：`record` 套件，輸出 m4a / aac
- 播放：`just_audio` 套件

**理由**：`docs/mvp.md` 指定；兩者為 Flutter 社群常用組合。

### 6. 拍照

**決定**：使用 `image_picker`，`ImageSource.camera` 直接開啟相機。

**理由**：MVP 只需單張拍照；比 `camera` 套件整合更簡單。

### 7. API 整合策略

**決定**：

1. **讀取**（列表、詳細）：直接串接既有 `GET /records`、`GET /records/{id}`
2. **寫入**（新增、上傳）：
   - **首選**：後端補齊 `POST /records`、`POST /upload/audio`、`POST /upload/image`（可在 `cip-lang-web` 另開 change）
   - **過渡方案**：若後端尚未就緒，App 以 mock repository 開發 UI，或暫以 placeholder URL 透過 `PUT /records/{id}` 更新 `audio_url` / `image_url`

**Dio 設定**：
- Base URL：`AppConfig.apiBaseUrl`（預設 `http://10.0.2.2:8280` Android 模擬器 / `http://localhost:8280` iOS 模擬器）
- 實機測試：改為開發機區網 IP
- 逾時：connect 10s、receive 30s（上傳媒體較慢）

### 8. 錯誤處理

**決定**：Repository 層捕捉 `DioException`，轉為 `AppException`（含使用者可讀繁中訊息）；UI 以 SnackBar 或 inline error 顯示。

### 9. UI 與主題

**決定**：依 `design/field_ethos/DESIGN.md` 的 Field Ethos 設計系統實作 Material 3 主題。

| Token | 值 |
|-------|-----|
| Primary | `#001813` |
| Surface | `#FBF9F8` |
| Secondary | `#47645E` |
| Error | `#BA1A1A` |

頁面布局參考 `design/record_list/code.html`（列表）、`design/new_record_form/code.html`（新增 wizard）、`design/mobile_record_detail/code.html`（詳細頁）。繁體中文文案硬編碼（MVP 不引入 i18n）。

## Risks / Trade-offs

| 風險 | 緩解 |
|------|------|
| 後端 POST / upload 端點未就緒 | 先以 mock 開發 UI；並行在 cip-lang-web 補 API |
| 實機無法連 localhost | 文件說明改用區網 IP；`AppConfig` 可設定 |
| 大檔上傳逾時 | Dio receive timeout 30s；顯示上傳進度 |
| iOS 權限審核嚴格 | Info.plist 加入麥克風、相機用途說明 |
| 錄音格式與後端不相容 | 統一輸出 aac/m4a；與後端協調接受格式 |

## Migration Plan

綠地專案，無 migration。部署步驟：

1. `flutter create` 初始化專案
2. 加入依賴與平台權限設定
3. 實作 features 並串接 API
4. `flutter run` 驗證模擬器；實機以區網 IP 測試

## Open Questions

- [ ] 後端 `POST /records` 與 upload 端點何時補齊？是否本 change 一併在 cip-lang-web 開 change？
- [ ] MVP 是否要求錄音與照片皆必填，或可僅上傳基本資料？
- [ ] 語料類型（category）預設選項清單為何？（例如：錄音、訪談、歌謠）
