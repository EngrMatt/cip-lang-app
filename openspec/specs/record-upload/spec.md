# record-upload

## Purpose

上傳功能：將語料基本資料、錄音與照片提交至後端 API。

## Requirements

### Requirement: 上傳基本資料

系統 SHALL 將語料基本資料（標題、類型、備註）上傳至後端。

#### Scenario: 成功上傳基本資料

- **WHEN** 使用者完成表單並觸發上傳
- **THEN** 系統呼叫 `POST /records` 建立語料並取得 record ID

#### Scenario: 上傳失敗

- **WHEN** 後端回傳錯誤或網路中斷
- **THEN** 系統顯示錯誤訊息並允許重試

### Requirement: 上傳錄音

系統 SHALL 將錄音檔上傳至後端並關聯至語料。

#### Scenario: 成功上傳錄音

- **WHEN** 使用者觸發上傳且已有錄音檔
- **THEN** 系統呼叫 `POST /upload/audio` 上傳錄音並更新語料的 `audio_url`

#### Scenario: 無錄音檔

- **WHEN** 使用者未錄音即嘗試上傳錄音
- **THEN** 系統提示需先完成錄音或允許跳過（若為選填）

### Requirement: 上傳照片

系統 SHALL 將照片上傳至後端並關聯至語料。

#### Scenario: 成功上傳照片

- **WHEN** 使用者觸發上傳且已有照片
- **THEN** 系統呼叫 `POST /upload/image` 上傳照片並更新語料的 `image_url`

#### Scenario: 無照片

- **WHEN** 使用者未拍照即嘗試上傳照片
- **THEN** 系統提示需先完成拍照或允許跳過（若為選填）

### Requirement: 上傳進度回饋

系統 SHALL 在上傳過程中提供進度或載入狀態回饋。

#### Scenario: 上傳進行中

- **WHEN** 上傳正在進行
- **THEN** 系統顯示載入指示並禁止重複提交

#### Scenario: 上傳完成

- **WHEN** 所有上傳步驟成功完成
- **THEN** 系統顯示成功訊息並導向語料列表或詳細頁
