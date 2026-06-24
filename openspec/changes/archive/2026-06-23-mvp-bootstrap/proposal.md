## Why

田野調查員需要在現場以手機快速採集語料（錄音、照片與基本資訊）並上傳至後端，供 `cip-lang-web` 管理後台集中瀏覽。目前 `cip-lang-app` 為綠地專案，尚無任何 Flutter 程式碼；依 `docs/mvp.md` 建立行動端 MVP，完成與既有 FastAPI 後端的資料上傳整合。

## What Changes

- 初始化 Flutter 3.x 專案（Riverpod、Dio、go_router）
- 實作語料列表頁（顯示標題、類型、建立日期；可進入詳細頁）
- 實作新增語料頁（標題、類型必填；備註選填）
- 實作錄音功能（開始 / 停止 / 重新錄音、預覽播放）
- 實作拍照功能（開啟相機、預覽、刪除）
- 實作上傳流程（基本資料、錄音、照片串接後端 API）
- 實作語料詳細頁（基本資訊、照片、錄音播放器）
- 設定 API base URL 與平台權限（麥克風、相機）

## Capabilities

### New Capabilities

- `record-list`：語料列表顯示與導覽至詳細頁、新增按鈕
- `record-create`：新增語料表單與欄位驗證
- `audio-capture`：錄音、停止、重新錄音與預覽播放
- `photo-capture`：拍照、預覽與刪除
- `record-upload`：將基本資料、錄音、照片上傳至後端
- `record-detail`：語料詳細頁，顯示資訊與媒體播放

### Modified Capabilities

（無 — `openspec/specs/` 目前為空）

## Non-goals

- **使用者驗證與權限管理**：MVP 不含登入流程
- **離線同步**：需網路連線才能上傳
- **GPS 定位**：Phase 2
- **AI 逐字稿 / 摘要**：Phase 2
- **Web 管理後台開發**：由 `cip-lang-web` 負責
- **生產環境部署**：MVP 僅涵蓋本地開發與實機測試

## Impact

- **新增**：Flutter 專案骨架（`lib/`、`pubspec.yaml`、平台設定）
- **依賴套件**：`flutter_riverpod`、`dio`、`go_router`、`record`、`just_audio`、`image_picker`
- **後端 API**：串接 `cip-lang-web` FastAPI（`GET /records`、`GET /records/{id}` 已就緒；`POST /records`、`POST /upload/audio`、`POST /upload/image` 可能需後端補齊或 App 端先以 PUT 更新 URL 欄位）
- **姊妹專案**：`cip-lang-web` 為資料接收與管理端；共用 Record 資料模型
- **平台**：iOS、Android（需麥克風與相機權限宣告）
