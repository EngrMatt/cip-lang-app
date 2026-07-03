## ADDED Requirements

### Requirement: 草稿自動儲存

系統 SHALL 在新增語料 wizard 各步驟自動儲存草稿至本地。

#### Scenario: 自動暫存

- **WHEN** 使用者修改表單、錄音或照片
- **THEN** 系統將進度寫入本地草稿

### Requirement: 離開提示

系統 SHALL 在離開 wizard 且尚有內容時提示是否儲存草稿。

#### Scenario: 離開確認

- **WHEN** 使用者嘗試關閉新增頁且已有內容
- **THEN** 系統詢問是否儲存草稿

### Requirement: 草稿恢復

系統 SHALL 在列表頁顯示未上傳草稿數並可恢復編輯。

#### Scenario: 草稿 banner

- **WHEN** 存在未上傳草稿
- **THEN** 系統於列表頂部顯示草稿數與繼續編輯入口
