# cip-lang-app 專案概覽

田野語料收集 **Flutter 純前端 App**（iOS + Android）。透過 REST API 與後端互動，讓田野調查人員在現場完成語料採集（錄音、拍照、填寫資訊與上傳）。

## 專案定位

| 項目 | 說明 |
|------|------|
| **架構** | 純前端 client，本 repo 不含後端程式碼 |
| **平台** | iOS、Android |
| **API 規格** | `docs/api.md` |
| **MVP 規格** | `docs/mvp.md` |
| **UI 設計稿** | `design/`（Field Ethos 設計系統） |

## MVP 範圍

| 功能 | 說明 |
|------|------|
| 語料列表 | 顯示標題、類型、建立日期；可進入詳細頁 |
| 新增語料 | 標題（必填）、類型（必填）、備註（選填） |
| 錄音 | 開始 / 停止 / 重新錄音、預覽播放 |
| 拍照 | 開啟相機、預覽、刪除 |
| 上傳 | 上傳基本資料、錄音、照片至後端 |
| 語料詳細 | 基本資訊、照片、錄音播放器 |

### MVP 明確排除（Phase 2）

- 帳號登入與驗證
- 離線背景同步（Phase 1.5 僅本地草稿）
- AI 逐字稿 / 摘要
- 分享與匯出

## Phase 1.5 能力（已完成）

| 功能 | 說明 |
|------|------|
| 調查員簽到 | 虛擬調查員姓名/地區，shared_preferences 持久化 |
| 列表篩選 | API category + 前端媒體狀態 Filter Chips |
| 族語符號列 | 標題/備註快捷輸入族語符號 |
| 錄音/播放波形 | audio_waveforms 即時波形與 seek |
| 草稿恢復 | Hive 本地草稿、離開提示、列表 banner |
| 照片裁剪 | image_cropper 拍照後裁剪 |
| 地圖採集點 | GPS 上傳、`GET /records/map`、marker 與圖卡 |

## 技術堆疊

| 層級 | 技術 |
|------|------|
| 框架 | Flutter 3.x |
| 語言 | Dart |
| 狀態管理 | Riverpod |
| 網路 | Dio |
| 錄音 | `record` + `audio_waveforms`（波形 UI） |
| 播放 | `just_audio` + `audio_waveforms` |
| 相機 | `image_picker` + `image_cropper` |
| 本地儲存 | `shared_preferences`（調查員、API URL）、`hive`（草稿） |
| 地圖 | `flutter_map` + OSM、`geolocator` |
| 媒體儲存 | AWS S3（透過 API 上傳；MVP 可先以 URL 字串對接後端） |

## 後端 API 整合

API 規格見 **`docs/api.md`**（預設 `https://cip-lang-test-20260624.nfs.tw`）。

| 方法 | 路徑 | 狀態 | 說明 |
|------|------|------|------|
| GET | `/records` | ✅ | 語料列表 |
| GET | `/records/map` | ✅ | 地圖採集點 |
| GET | `/records/{id}` | ✅ | 語料詳細 |
| PUT | `/records/{id}` | ✅ | 更新語料 |
| POST | `/records` | ✅ | 新增語料（含 GPS） |
| POST | `/upload/audio` | ✅ | 上傳錄音 |
| POST | `/upload/image` | ✅ | 上傳照片 |

實機測試請用：`flutter run --dart-define=API_BASE_URL=http://<你的電腦IP>:8280`

### Record 資料模型

| 欄位 | 類型 | 必填 | 說明 |
|------|------|------|------|
| `id` | integer | — | 主鍵 |
| `title` | string | ✅ | 標題 |
| `category` | string | ✅ | 類型（App 稱「語料類型」） |
| `note` | string \| null | — | 備註 |
| `audio_url` | string \| null | — | 錄音 URL |
| `image_url` | string \| null | — | 照片 URL |
| `latitude` | number \| null | — | 緯度（WGS84） |
| `longitude` | number \| null | — | 經度（WGS84） |
| `created_at` | datetime | — | 建立時間（ISO 8601 UTC） |

## 專案結構（規劃）

```text
cip-lang-app/
├── lib/
│   ├── main.dart
│   ├── app.dart                 # MaterialApp、路由、主題
│   ├── core/
│   │   ├── config/              # API base URL 等設定
│   │   └── network/             # Dio client、攔截器
│   ├── features/
│   │   ├── onboarding/          # 調查員簽到
│   │   ├── drafts/              # 本地草稿
│   │   ├── input/               # 族語符號輸入
│   │   ├── records/             # 列表、詳細、新增
│   │   ├── explore/             # 地圖採集點
│   │   ├── location/            # GPS 定位
│   │   ├── audio/               # 錄音與播放
│   │   └── camera/              # 拍照與預覽
│   ├── models/                  # Record 等資料模型
│   └── providers/               # Riverpod providers
├── docs/
│   └── mvp.md                   # MVP 原始規格
├── openspec/                    # OpenSpec 規格與變更管理
│   ├── config.yaml
│   ├── project.md
│   ├── specs/                   # 系統行為的單一真相來源
│   └── changes/                 # 進行中的變更提案
└── pubspec.yaml
```

## 畫面規劃

| Screen | 頁面 |
|--------|------|
| 01 | 語料列表頁 |
| 02 | 新增語料頁 |
| 03 | 錄音介面 |
| 04 | 照片管理 |
| 05 | 語料詳細頁 |

## 領域知識

- **CIP**：原住民委員會（Council of Indigenous Peoples）相關專案脈絡
- **田野語料**：含語音錄音、現場照片與採集 metadata 的語言學研究資料
- **UI 語言**：繁體中文；預留族語文字顯示能力

## 慣例

### 程式碼風格

- Dart 官方 style guide
- 檔案命名：snake_case（`record_list_page.dart`）
- Widget / 類別：PascalCase；變數 / 函式：camelCase
- 功能模組化：`features/<feature>/` 分層（presentation / providers / widgets）
- 保持 diff 最小化，不過度抽象

### Git 與提交

- Conventional commits（`feat:`、`fix:`、`refactor:` 等）
- 僅在明確要求時才建立 commit
- 不提交 `.env`、憑證、API key 或機密檔案

### 狀態管理

- Riverpod 作為唯一狀態管理方案
- API 呼叫封裝於 repository / service 層，Widget 不直接呼叫 Dio

### 測試

- 單元測試：`flutter test`（note 前綴注入等）
- Widget 測試：App smoke test
- 優先測試真實行為，避免瑣碎斷言

### 平台權限

- iOS / Android 需宣告麥克風、相機、儲存空間、定位權限
- 錄音、拍照與 GPS 採集前檢查並引導使用者授權

## 開發工作流

本專案使用 **OpenSpec OPSX 工作流**（schema: `spec-driven`）：

1. `/opsx:propose` — 建立變更提案（proposal → specs → design → tasks）
2. `/opsx:apply` — 依 tasks 實作
3. `/opsx:archive` — 歸檔完成的變更，合併 spec 至主規格

探索想法但不實作時使用 `/opsx:explore`。

## 環境與部署

- 開發：`flutter run`（待 scaffold 後可用）
- API 連線：開發環境指向 `http://localhost:8280`（實機測試需改用區網 IP 或 ngrok）
- 目標平台：iOS、Android（MVP 優先 Android 或雙平台）

## 姊妹專案

| 專案 | 角色 | 路徑 |
|------|------|------|
| `cip-lang-web` | Web 管理後台 + FastAPI 後端 | `../cip-lang-web` |
| `cip_idp_service` | 戶籍謄本 IDP（獨立） | 同 POC 目錄 |

---

> **注意**：此檔案為專案 context，供 AI 規劃與實作時參考。內容已同步至 `openspec/config.yaml` 的 `context:` 區段。
