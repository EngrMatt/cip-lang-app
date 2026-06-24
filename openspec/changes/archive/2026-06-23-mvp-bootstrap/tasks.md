## 1. 專案初始化

- [x] 1.1 使用 `flutter create` 建立專案骨架
- [x] 1.2 加入依賴：`flutter_riverpod`、`dio`、`go_router`、`record`、`just_audio`、`image_picker`
- [x] 1.3 設定 Android / iOS 麥克風與相機權限（AndroidManifest、Info.plist）
- [x] 1.4 建立 `lib/core/config/app_config.dart`（API base URL 設定）
- [x] 1.5 建立 `lib/core/network/dio_client.dart` 與錯誤處理

## 2. 資料模型與 API 層

- [x] 2.1 建立 `lib/models/record.dart`（對應後端 Record 模型）
- [x] 2.2 建立 `lib/features/records/data/record_repository.dart`（GET /records、GET /records/{id}）
- [x] 2.3 建立 Riverpod providers（`recordsListProvider`、`recordDetailProvider`）
- [x] 2.4 若後端 POST 端點就緒，實作 create / upload 方法；否則建立 mock repository

## 3. 路由與 App 骨架

- [x] 3.1 設定 `go_router` 路由（`/`、`/records/new`、`/records/:id`）
- [x] 3.2 建立 `lib/app.dart`（MaterialApp、主題、ProviderScope）
- [x] 3.3 建立共用 UI 元件（載入中、錯誤、空狀態）

## 4. 語料列表頁

- [x] 4.1 建立 `RecordListPage` 與列表 UI
- [x] 4.2 串接 `GET /records` 顯示標題、類型、建立日期
- [x] 4.3 實作點擊導向詳細頁與新增按鈕
- [x] 4.4 加入載入中、錯誤、空狀態處理

## 5. 新增語料 Wizard

- [x] 5.1 建立多步驟 wizard 狀態（`CreateRecordNotifier`）
- [x] 5.2 實作基本資料表單頁（標題、類型、備註與驗證）
- [x] 5.3 整合錄音步驟（見第 6 節）
- [x] 5.4 整合拍照步驟（見第 7 節）
- [x] 5.5 實作上傳確認頁與提交流程

## 6. 錄音功能

- [x] 6.1 建立 `AudioRecorderService`（record 套件封裝）
- [x] 6.2 實作開始 / 停止 / 重新錄音 UI
- [x] 6.3 實作錄音預覽播放（just_audio）
- [x] 6.4 處理麥克風權限請求與拒絕狀態

## 7. 拍照功能

- [x] 7.1 建立 `PhotoCaptureService`（image_picker 封裝）
- [x] 7.2 實作拍照、預覽、刪除 UI
- [x] 7.3 處理相機權限請求與拒絕狀態

## 8. 上傳功能

- [x] 8.1 實作 `POST /records` 上傳基本資料
- [x] 8.2 實作 `POST /upload/audio` 上傳錄音
- [x] 8.3 實作 `POST /upload/image` 上傳照片
- [x] 8.4 上傳進度與成功 / 失敗回饋（SnackBar）
- [x] 8.5 上傳完成後導向列表或詳細頁

## 9. 語料詳細頁

- [x] 9.1 建立 `RecordDetailPage` 顯示基本資訊
- [x] 9.2 顯示照片預覽（有 / 無照片狀態）
- [x] 9.3 實作錄音播放器（有 / 無錄音狀態）
- [x] 9.4 處理 404 與載入錯誤

## 10. 整合驗證

- [x] 10.1 確認 `flutter run` 可啟動 App（模擬器）
- [x] 10.2 端到端驗證：新增 → 錄音 → 拍照 → 上傳 → 列表 → 詳細
- [x] 10.3 確認與後端 API 串接（GET 已就緒；POST 端點待後端補齊）
