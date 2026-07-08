# record-detail

## Purpose

語料詳細頁：顯示基本資訊、照片與錄音播放。

## Requirements

### Requirement: 顯示語料詳細資訊

系統 SHALL 在詳細頁顯示語料的基本資訊。

#### Scenario: 成功載入詳細資料

- **WHEN** 使用者進入語料詳細頁
- **THEN** 系統顯示標題、類型、備註與建立日期

#### Scenario: 語料不存在

- **WHEN** 後端回傳 404
- **THEN** 系統顯示語料不存在的錯誤訊息

### Requirement: 顯示照片

系統 SHALL 在詳細頁顯示語料關聯的照片（若有）。

#### Scenario: 有照片 URL

- **WHEN** 語料包含 `image_url`
- **THEN** 系統顯示照片預覽

#### Scenario: 無照片

- **WHEN** 語料無 `image_url`
- **THEN** 系統顯示無照片的佔位狀態

### Requirement: 錄音播放

系統 SHALL 在詳細頁提供錄音播放功能（若有錄音）。

#### Scenario: 播放錄音

- **WHEN** 語料包含 `audio_url` 且使用者點擊播放
- **THEN** 系統播放錄音內容

#### Scenario: 無錄音

- **WHEN** 語料無 `audio_url`
- **THEN** 系統顯示無錄音的佔位狀態

### Requirement: 播放波形顯示

系統 SHALL 在詳細頁播放錄音時顯示波形並支援 seek；波形載入失敗時仍可播放。

#### Scenario: 播放波形

- **WHEN** 語料含 audio_url 且波形載入成功
- **THEN** 系統顯示可 seek 的播放波形

### Requirement: 刪除語料

系統 SHALL 在詳細頁提供刪除語料功能，並於刪除前要求確認。

#### Scenario: 確認後刪除

- **WHEN** 使用者點擊刪除並確認
- **THEN** 系統呼叫 `DELETE /records/{id}`，成功後返回列表並刷新

#### Scenario: 取消刪除

- **WHEN** 使用者在確認對話框點擊取消
- **THEN** 系統不執行刪除
