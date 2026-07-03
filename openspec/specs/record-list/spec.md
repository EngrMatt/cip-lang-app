# record-list

## Purpose

語料列表頁：顯示已上傳語料、導覽至詳細頁與新增流程。

## Requirements

### Requirement: 顯示語料列表

系統 SHALL 以列表形式顯示語料紀錄，每筆包含標題、類型與建立日期，並支援依類型與媒體狀態篩選。

#### Scenario: 成功載入語料列表

- **WHEN** 使用者開啟語料列表頁
- **THEN** 系統顯示語料列表，每筆包含標題、類型（category）與建立日期（created_at）

#### Scenario: API 載入失敗

- **WHEN** 後端 API 無法連線或回傳錯誤
- **THEN** 系統顯示錯誤訊息並提供重試選項

#### Scenario: 列表為空

- **WHEN** 後端回傳空列表
- **THEN** 系統顯示空狀態提示

#### Scenario: 依類型篩選

- **WHEN** 使用者選擇類型 Filter Chip
- **THEN** 系統以 `category` 參數重新載入列表

#### Scenario: 依媒體狀態篩選

- **WHEN** 使用者選擇「含錄音」「含照片」或「僅基本資料」
- **THEN** 系統在前端依 `audio_url` / `image_url` 篩選已載入項目

### Requirement: 導覽至詳細頁

系統 SHALL 允許使用者從列表進入語料詳細頁。

#### Scenario: 點擊列表項目

- **WHEN** 使用者點擊某一筆語料
- **THEN** 系統導向該語料的詳細頁

### Requirement: 新增語料入口

系統 SHALL 在列表頁提供新增語料的入口。

#### Scenario: 點擊新增按鈕

- **WHEN** 使用者點擊新增語料按鈕
- **THEN** 系統導向新增語料流程
