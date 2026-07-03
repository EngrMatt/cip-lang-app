## ADDED Requirements

### Requirement: 調查員簽到

系統 SHALL 在首次啟動或無已儲存 profile 時顯示簽到頁，收集調查員姓名（必填）與地區（選填）。

#### Scenario: 首次啟動

- **WHEN** 使用者首次開啟 App 且無已儲存 profile
- **THEN** 系統導向簽到頁

#### Scenario: 簽到完成

- **WHEN** 使用者填寫姓名並提交
- **THEN** 系統儲存 profile 並導向語料列表

### Requirement: 調查員資訊注入備註

系統 SHALL 在上傳語料時將調查員資訊以 `[調查員: 姓名 | 地區]` 格式寫入 note 前綴。

#### Scenario: 上傳含調查員前綴

- **WHEN** 使用者完成上傳且已簽到
- **THEN** 系統將調查員前綴與使用者備註合併後送至 API

### Requirement: 切換調查員

系統 SHALL 在列表頁提供切換調查員入口。

#### Scenario: 切換調查員

- **WHEN** 使用者點擊切換調查員
- **THEN** 系統導向簽到頁並可更新 profile
